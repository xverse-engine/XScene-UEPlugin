import numpy as np
import torch
from icecream import ic
from utils.graphics_utils import getWorld2View2


def normalize(x):
    return x / np.linalg.norm(x)

def viewmatrix(z, up, pos):
    vec2 = normalize(z)
    vec1_avg = up
    vec0 = normalize(np.cross(vec1_avg, vec2))
    vec1 = normalize(np.cross(vec2, vec0))
    m = np.stack([vec0, vec1, vec2, pos], 1)
    return m

def poses_avg(poses):
    hwf = poses[0, :3, -1:]

    center = poses[:, :3, 3].mean(0)
    vec2 = normalize(poses[:, :3, 2].sum(0))
    up = poses[:, :3, 1].sum(0)
    c2w = np.concatenate([viewmatrix(vec2, up, center), hwf], 1)

    return c2w

def get_focal(camera):
    focal = camera.FoVx
    return focal

def poses_avg_fixed_center(poses):
    hwf = poses[0, :3, -1:]
    center = poses[:, :3, 3].mean(0)
    vec2 = [1, 0, 0]
    up = [0, 0, 1]
    c2w = np.concatenate([viewmatrix(vec2, up, center), hwf], 1)
    return c2w

def integrate_weights_np(w):
    """Compute the cumulative sum of w, assuming all weight vectors sum to 1.

  The output's size on the last dimension is one greater than that of the input,
  because we're computing the integral corresponding to the endpoints of a step
  function, not the integral of the interior/bin values.

  Args:
    w: Tensor, which will be integrated along the last axis. This is assumed to
      sum to 1 along the last axis, and this function will (silently) break if
      that is not the case.

  Returns:
    cw0: Tensor, the integral of w, where cw0[..., 0] = 0 and cw0[..., -1] = 1
  """
    cw = np.minimum(1, np.cumsum(w[..., :-1], axis=-1))
    shape = cw.shape[:-1] + (1,)
    # Ensure that the CDF starts with exactly 0 and ends with exactly 1.
    cw0 = np.concatenate([np.zeros(shape), cw,
                          np.ones(shape)], axis=-1)
    return cw0

def invert_cdf_np(u, t, w_logits):
    """Invert the CDF defined by (t, w) at the points specified by u in [0, 1)."""
    # Compute the PDF and CDF for each weight vector.
    w = np.exp(w_logits) / np.exp(w_logits).sum(axis=-1, keepdims=True)
    cw = integrate_weights_np(w)
    # Interpolate into the inverse CDF.
    interp_fn = np.interp
    t_new = interp_fn(u, cw, t)
    return t_new

def sample_np(rand,
              t,
              w_logits,
              num_samples,
              single_jitter=False,
              deterministic_center=False):
    """
    numpy version of sample()
  """
    eps = np.finfo(np.float32).eps

    # Draw uniform samples.
    if not rand:
        if deterministic_center:
            pad = 1 / (2 * num_samples)
            u = np.linspace(pad, 1. - pad - eps, num_samples)
        else:
            u = np.linspace(0, 1. - eps, num_samples)
        u = np.broadcast_to(u, t.shape[:-1] + (num_samples,))
    else:
        # `u` is in [0, 1) --- it can be zero, but it can never be 1.
        u_max = eps + (1 - eps) / num_samples
        max_jitter = (1 - u_max) / (num_samples - 1) - eps
        d = 1 if single_jitter else num_samples
        u = np.linspace(0, 1 - u_max, num_samples) + \
            np.random.rand(*t.shape[:-1], d) * max_jitter

    return invert_cdf_np(u, t, w_logits)



def focus_point_fn(poses):
    """Calculate nearest point to all focal axes in poses."""
    directions, origins = poses[:, :3, 2:3], poses[:, :3, 3:4]
    m = np.eye(3) - directions * np.transpose(directions, [0, 2, 1])
    mt_m = np.transpose(m, [0, 2, 1]) @ m
    focus_pt = np.linalg.inv(mt_m.mean(0)) @ (mt_m @ origins).mean(0)[:, 0]
    return focus_pt


def average_pose(poses: np.ndarray) -> np.ndarray:
  """New pose using average position, z-axis, and up vector of input poses."""
  position = poses[:, :3, 3].mean(0)
  z_axis = poses[:, :3, 2].mean(0)
  up = poses[:, :3, 1].mean(0)
  cam2world = viewmatrix(z_axis, up, position)
  return cam2world

from typing import Tuple
def recenter_poses(poses: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
  """Recenter poses around the origin."""
  cam2world = average_pose(poses)
  transform = np.linalg.inv(pad_poses(cam2world))
  poses = transform @ pad_poses(poses)
  return unpad_poses(poses), transform


NEAR_STRETCH = .9  # Push forward near bound for forward facing render path.
FAR_STRETCH = 5.  # Push back far bound for forward facing render path.
FOCUS_DISTANCE = .75  # Relative weighting of near, far bounds for render path.
def generate_spiral_path(views, bounds,
                         n_frames: int = 180,
                         n_rots: int = 2,
                         zrate: float = .5) -> np.ndarray:
  """Calculates a forward facing spiral path for rendering."""
  # Find a reasonable 'focus depth' for this dataset as a weighted average
  # of conservative near and far bounds in disparity space.
  poses = []
  for view in views:
      tmp_view = np.eye(4)
      tmp_view[:3] = np.concatenate([view.R.T, view.T[:, None]], 1)
      tmp_view = np.linalg.inv(tmp_view)
      tmp_view[:, 1:3] *= -1
      poses.append(tmp_view)
  poses = np.stack(poses, 0)

  print(poses.shape)
  bounds  = bounds.repeat(poses.shape[0], 0) #np.array([[ 16.21311152, 153.86329729]])
  scale = 1. / (bounds.min() * .75)
  poses[:, :3, 3] *= scale
  bounds *= scale
  # Recenter poses.
  # tmp, _ = recenter_poses(poses)
  # poses[:, :3, :3] = tmp[:, :3, :3] @ np.diag(np.array([1, -1, -1]))

  near_bound = bounds.min() * NEAR_STRETCH
  far_bound = bounds.max() * FAR_STRETCH
  # All cameras will point towards the world space point (0, 0, -focal).
  focal = 1 / (((1 - FOCUS_DISTANCE) / near_bound + FOCUS_DISTANCE / far_bound))

  # Get radii for spiral path using 90th percentile of camera positions.
  positions = poses[:, :3, 3]
  radii = np.percentile(np.abs(positions), 90, 0)
  radii = np.concatenate([radii, [1.]])

  # Generate poses for spiral path.
  render_poses = []
  cam2world = average_pose(poses)
  up = poses[:, :3, 1].mean(0)
  for theta in np.linspace(0., 2. * np.pi * n_rots, n_frames, endpoint=False):
    t = radii * [np.cos(theta), -np.sin(theta), -np.sin(theta * zrate), 1.]
    position = cam2world @ t
    lookat = cam2world @ [0, 0, -focal, 1.]
    z_axis = position - lookat
    render_pose = np.eye(4)
    render_pose[:3] = viewmatrix(z_axis, up, position)
    render_pose[:3, 1:3] *= -1
    render_poses.append(np.linalg.inv(render_pose))
  render_poses = np.stack(render_poses, axis=0)
  return render_poses


def render_path_spiral(views, focal=50, zrate=0.5, rots=2, N=10):
    poses = []
    for view in views:
        tmp_view = np.eye(4)
        tmp_view[:3] = np.concatenate([view.R.T, view.T[:, None]], 1)
        tmp_view = np.linalg.inv(tmp_view)
        tmp_view[:, 1:3] *= -1
        poses.append(tmp_view)
    poses = np.stack(poses, 0)
    # poses = np.stack([np.concatenate([view.R.T, view.T[:, None]], 1) for view in views], 0)
    c2w = poses_avg(poses)
    up = normalize(poses[:, :3, 1].sum(0))

    # Get radii for spiral path
    rads = np.percentile(np.abs(poses[:, :3, 3]), 90, 0)
    render_poses = []
    rads = np.array(list(rads) + [1.0])

    for theta in np.linspace(0.0, 2.0 * np.pi * rots, N + 1)[:-1]:
        c = np.dot(
            c2w[:3, :4],
            np.array([np.cos(theta), -np.sin(theta), -np.sin(theta * zrate), 1.0]) * rads,
        )
        z = normalize(c - np.dot(c2w[:3, :4], np.array([0, 0, -focal, 1.0])))
        render_pose = np.eye(4)
        render_pose[:3] = viewmatrix(z, up, c)
        render_pose[:3, 1:3] *= -1
        render_poses.append(np.linalg.inv(render_pose))
    return render_poses

def pad_poses(p):
    """Pad [..., 3, 4] pose matrices with a homogeneous bottom row [0,0,0,1]."""
    bottom = np.broadcast_to([0, 0, 0, 1.], p[..., :1, :4].shape)
    return np.concatenate([p[..., :3, :4], bottom], axis=-2)


def unpad_poses(p):
    """Remove the homogeneous bottom row from [..., 4, 4] pose matrices."""
    return p[..., :3, :4]

def transform_poses_pca(poses):
    """Transforms poses so principal components lie on XYZ axes.

  Args:
    poses: a (N, 3, 4) array containing the cameras' camera to world transforms.

  Returns:
    A tuple (poses, transform), with the transformed poses and the applied
    camera_to_world transforms.
  """
    t = poses[:, :3, 3]
    t_mean = t.mean(axis=0)
    t = t - t_mean

    eigval, eigvec = np.linalg.eig(t.T @ t)
    # Sort eigenvectors in order of largest to smallest eigenvalue.
    inds = np.argsort(eigval)[::-1]
    eigvec = eigvec[:, inds]
    rot = eigvec.T
    if np.linalg.det(rot) < 0:
        rot = np.diag(np.array([1, 1, -1])) @ rot

    transform = np.concatenate([rot, rot @ -t_mean[:, None]], -1)
    poses_recentered = unpad_poses(transform @ pad_poses(poses))
    transform = np.concatenate([transform, np.eye(4)[3:]], axis=0)

    # Flip coordinate system if z component of y-axis is negative
    if poses_recentered.mean(axis=0)[2, 1] < 0:
        poses_recentered = np.diag(np.array([1, -1, -1])) @ poses_recentered
        transform = np.diag(np.array([1, -1, -1, 1])) @ transform

    # Just make sure it's it in the [-1, 1]^3 cube
    scale_factor = 1. / np.max(np.abs(poses_recentered[:, :3, 3]))
    poses_recentered[:, :3, 3] *= scale_factor
    transform = np.diag(np.array([scale_factor] * 3 + [1])) @ transform
    return poses_recentered, transform

def generate_ellipse_path(views, n_frames=600, const_speed=True, z_variation=0., z_phase=0.):
    poses = []
    for view in views:
        tmp_view = np.eye(4)
        tmp_view[:3] = np.concatenate([view.R.T, view.T[:, None]], 1)
        tmp_view = np.linalg.inv(tmp_view)
        tmp_view[:, 1:3] *= -1
        poses.append(tmp_view)
    poses = np.stack(poses, 0)
    poses, transform = transform_poses_pca(poses)


    # Calculate the focal point for the path (cameras point toward this).
    center = focus_point_fn(poses)
    offset = np.array([center[0] , center[1],  center[2]*0 ])
    # Calculate scaling for ellipse axes based on input camera positions.
    sc = np.percentile(np.abs(poses[:, :3, 3] - offset), 90, axis=0)

    # Use ellipse that is symmetric about the focal point in xy.
    low = -sc + offset
    high = sc + offset
    # Optional height variation need not be symmetric
    z_low = np.percentile((poses[:, :3, 3]), 10, axis=0)
    z_high = np.percentile((poses[:, :3, 3]), 90, axis=0)


    def get_positions(theta):
        # Interpolate between bounds with trig functions to get ellipse in x-y.
        # Optionally also interpolate in z to change camera height along path.
        return np.stack([
            (low[0] + (high - low)[0] * (np.cos(theta) * .5 + .5)),
            (low[1] + (high - low)[1] * (np.sin(theta) * .5 + .5)),
            z_variation * (z_low[2] + (z_high - z_low)[2] *
                           (np.cos(theta + 2 * np.pi * z_phase) * .5 + .5)),
        ], -1)

    theta = np.linspace(0, 2. * np.pi, n_frames + 1, endpoint=True)
    positions = get_positions(theta)

    if const_speed:
        # Resample theta angles so that the velocity is closer to constant.
        lengths = np.linalg.norm(positions[1:] - positions[:-1], axis=-1)
        theta = sample_np(None, theta, np.log(lengths), n_frames + 1)
        positions = get_positions(theta)

    # Throw away duplicated last position.
    positions = positions[:-1]

    # Set path's up vector to axis closest to average of input pose up vectors.
    avg_up = poses[:, :3, 1].mean(0)
    avg_up = avg_up / np.linalg.norm(avg_up)
    ind_up = np.argmax(np.abs(avg_up))
    up = np.eye(3)[ind_up] * np.sign(avg_up[ind_up])

    render_poses = []
    for p in positions:
        render_pose = np.eye(4)
        render_pose[:3] = viewmatrix(p - center, up, p)
        render_pose = np.linalg.inv(transform) @ render_pose
        render_pose[:3, 1:3] *= -1
        render_poses.append(np.linalg.inv(render_pose))
    return render_poses


def generate_spherify_path(views):
    poses = []
    for view in views:
        tmp_view = np.eye(4)
        tmp_view[:3] = np.concatenate([view.R.T, view.T[:, None]], 1)
        tmp_view = np.linalg.inv(tmp_view)
        tmp_view[:, 1:3] *= -1
        poses.append(tmp_view)
    poses = np.stack(poses, 0)

    p34_to_44 = lambda p: np.concatenate(
        [p, np.tile(np.reshape(np.eye(4)[-1, :], [1, 1, 4]), [p.shape[0], 1, 1])], 1
    )

    rays_d = poses[:, :3, 2:3]
    rays_o = poses[:, :3, 3:4]

    def min_line_dist(rays_o, rays_d):
        A_i = np.eye(3) - rays_d * np.transpose(rays_d, [0, 2, 1])
        b_i = -A_i @ rays_o
        pt_mindist = np.squeeze(
            -np.linalg.inv((np.transpose(A_i, [0, 2, 1]) @ A_i).mean(0)) @ (b_i).mean(0)
        )
        return pt_mindist

    pt_mindist = min_line_dist(rays_o, rays_d)

    center = pt_mindist
    up = (poses[:, :3, 3] - center).mean(0)

    vec0 = normalize(up)
    vec1 = normalize(np.cross([0.1, 0.2, 0.3], vec0))
    vec2 = normalize(np.cross(vec0, vec1))
    pos = center
    c2w = np.stack([vec1, vec2, vec0, pos], 1)

    poses_reset = np.linalg.inv(p34_to_44(c2w[None])) @ p34_to_44(poses[:, :3, :4])

    rad = np.sqrt(np.mean(np.sum(np.square(poses_reset[:, :3, 3]), -1)))

    sc = 1.0 / rad
    poses_reset[:, :3, 3] *= sc
    rad *= sc

    centroid = np.mean(poses_reset[:, :3, 3], 0)
    zh = centroid[2]
    radcircle = np.sqrt(rad**2 - zh**2)
    new_poses = []

    for th in np.linspace(0.0, 2.0 * np.pi, 120):
        camorigin = np.array([radcircle * np.cos(th), radcircle * np.sin(th), zh])
        up = np.array([0, 0, -1.0])

        vec2 = normalize(camorigin)
        vec0 = normalize(np.cross(vec2, up))
        vec1 = normalize(np.cross(vec2, vec0))
        pos = camorigin
        p = np.stack([vec0, vec1, vec2, pos], 1)

        render_pose = np.eye(4)
        render_pose[:3] = p
        #render_pose[:3, 1:3] *= -1
        new_poses.append(render_pose)

    new_poses = np.stack(new_poses, 0)
    return new_poses

# def gaussian_poses(viewpoint_cam, mean =0, std_dev = 0.03):
#     translate_x = np.random.normal(mean, std_dev)
#     translate_y = np.random.normal(mean, std_dev)
#     translate_z = np.random.normal(mean, std_dev)
#     translate = np.array([translate_x, translate_y, translate_z])
#     viewpoint_cam.world_view_transform = torch.tensor(getWorld2View2(viewpoint_cam.R, viewpoint_cam.T, translate)).transpose(0, 1).cuda()
#     viewpoint_cam.full_proj_transform = (viewpoint_cam.world_view_transform.unsqueeze(0).bmm(viewpoint_cam.projection_matrix.unsqueeze(0))).squeeze(0)
#     viewpoint_cam.camera_center = viewpoint_cam.world_view_transform.inverse()[3, :3]
#     return viewpoint_cam

def get_rotation_matrix(axis, angle):
    """
    Create a rotation matrix for a given axis (x, y, or z) and angle.
    """
    axis = axis.lower()
    cos_angle = np.cos(angle)
    sin_angle = np.sin(angle)

    if axis == 'x':
        return np.array([
            [1, 0, 0],
            [0, cos_angle, -sin_angle],
            [0, sin_angle, cos_angle]
        ])
    elif axis == 'y':
        return np.array([
            [cos_angle, 0, sin_angle],
            [0, 1, 0],
            [-sin_angle, 0, cos_angle]
        ])
    elif axis == 'z':
        return np.array([
            [cos_angle, -sin_angle, 0],
            [sin_angle, cos_angle, 0],
            [0, 0, 1]
        ])
    else:
        raise ValueError("Invalid axis. Choose from 'x', 'y', 'z'.")



def gaussian_poses(viewpoint_cam, mean=0, std_dev_translation=0.03, std_dev_rotation=0.01):
    # Translation Perturbation
    translate_x = np.random.normal(mean, std_dev_translation)
    translate_y = np.random.normal(mean, std_dev_translation)
    translate_z = np.random.normal(mean, std_dev_translation)
    translate = np.array([translate_x, translate_y, translate_z])

    # Rotation Perturbation
    angle_x = np.random.normal(mean, std_dev_rotation)
    angle_y = np.random.normal(mean, std_dev_rotation)
    angle_z = np.random.normal(mean, std_dev_rotation)

    rot_x = get_rotation_matrix('x', angle_x)
    rot_y = get_rotation_matrix('y', angle_y)
    rot_z = get_rotation_matrix('z', angle_z)

    # Combined Rotation Matrix
    combined_rot = np.matmul(rot_z, np.matmul(rot_y, rot_x))

    # Apply Rotation to Camera
    rotated_R = np.matmul(viewpoint_cam.R, combined_rot)

    # Update Camera Transformation
    viewpoint_cam.world_view_transform = torch.tensor(getWorld2View2(rotated_R, viewpoint_cam.T, translate)).transpose(0, 1).cuda()
    viewpoint_cam.full_proj_transform = (viewpoint_cam.world_view_transform.unsqueeze(0).bmm(viewpoint_cam.projection_matrix.unsqueeze(0))).squeeze(0)
    viewpoint_cam.camera_center = viewpoint_cam.world_view_transform.inverse()[3, :3]

    return viewpoint_cam



def circular_poses(viewpoint_cam, radius, angle=0.0):
    translate_x = radius * np.cos(angle)
    translate_y = radius * np.sin(angle)
    translate_z = 0
    translate = np.array([translate_x, translate_y, translate_z])
    viewpoint_cam.world_view_transform = torch.tensor(getWorld2View2(viewpoint_cam.R, viewpoint_cam.T, translate)).transpose(0, 1).cuda()
    viewpoint_cam.full_proj_transform = (viewpoint_cam.world_view_transform.unsqueeze(0).bmm(viewpoint_cam.projection_matrix.unsqueeze(0))).squeeze(0)
    viewpoint_cam.camera_center = viewpoint_cam.world_view_transform.inverse()[3, :3]

    return viewpoint_cam

def generate_spherical_sample_path(views, azimuthal_rots=1, polar_rots=0.75, N=10):
    poses = []
    for view in views:
        tmp_view = np.eye(4)
        tmp_view[:3] = np.concatenate([view.R.T, view.T[:, None]], 1)
        tmp_view = np.linalg.inv(tmp_view)
        tmp_view[:, 1:3] *= -1
        poses.append(tmp_view)
        focal = get_focal(view)
    poses = np.stack(poses, 0)
    # ic(min_focal, max_focal)
    
    c2w = poses_avg(poses)  
    up = normalize(poses[:, :3, 1].sum(0))  
    rads = np.percentile(np.abs(poses[:, :3, 3]), 90, 0)
    rads = np.array(list(rads) + [1.0])
    ic(rads)
    render_poses = []
    focal_range = np.linspace(0.5, 3, N **2+1)
    index = 0
    # Modify this loop to include phi
    for theta in np.linspace(0.0, 2.0 * np.pi * azimuthal_rots, N + 1)[:-1]:
        for phi in np.linspace(0.0, np.pi * polar_rots, N + 1)[:-1]:
            # Modify these lines to use spherical coordinates for c
            c = np.dot(
                c2w[:3, :4],
                rads * np.array([
                    np.sin(phi) * np.cos(theta),
                    np.sin(phi) * np.sin(theta),
                    np.cos(phi),
                    1.0
                ])
            )
            
            z = normalize(c - np.dot(c2w[:3, :4], np.array([0, 0, -focal_range[index], 1.0])))
            render_pose = np.eye(4)
            render_pose[:3] = viewmatrix(z, up, c)  
            render_pose[:3, 1:3] *= -1
            render_poses.append(np.linalg.inv(render_pose))
            index += 1
    return render_poses


def generate_spiral_path(views, focal=1.5, zrate= 0, rots=1, N=600):
    poses = []
    focal = 0
    for view in views:
        tmp_view = np.eye(4)
        tmp_view[:3] = np.concatenate([view.R.T, view.T[:, None]], 1)
        tmp_view = np.linalg.inv(tmp_view)
        tmp_view[:, 1:3] *= -1
        poses.append(tmp_view)
        focal += get_focal(views[0])
    poses = np.stack(poses, 0)


    c2w = poses_avg(poses)
    up = normalize(poses[:, :3, 1].sum(0))

    # Get radii for spiral path
    rads = np.percentile(np.abs(poses[:, :3, 3]), 90, 0)
    render_poses = []

    rads = np.array(list(rads) + [1.0])
    focal /= len(views)

    for theta in np.linspace(0.0, 2.0 * np.pi * rots, N + 1)[:-1]:
        c = np.dot(
            c2w[:3, :4],
            np.array([np.cos(theta), -np.sin(theta),-np.sin(theta * zrate), 1.0]) * rads,
        )
        z = normalize(c - np.dot(c2w[:3, :4], np.array([0, 0, -focal, 1.0])))

        render_pose = np.eye(4)
        render_pose[:3] = viewmatrix(z, up, c)
        render_pose[:3, 1:3] *= -1
        render_poses.append(np.linalg.inv(render_pose))
    return render_poses
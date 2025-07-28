// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;

public class GSImporter : ModuleRules
{
	public GSImporter(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = ModuleRules.PCHUsageMode.UseExplicitOrSharedPCHs; 
        bEnableExceptions = true;
        bUseRTTI = true;
        bUsePrecompiled = true;
        PublicIncludePaths.AddRange(
			new string[] {
				// ... add public include paths required here ...
			}
			);
				
		
		PrivateIncludePaths.AddRange(
			new string[] {
				// ... add other private include paths required here ...
			}
			);
			
		
		PublicDependencyModuleNames.AddRange(
			new string[]
			{
				"Core",
				// ... add other public dependencies that you statically link with here ...
				 "GSRuntime",
            }
			);
			
		
		PrivateDependencyModuleNames.AddRange(
			new string[]
			{
				"Projects",
				"InputCore",
				"EditorFramework",
				"UnrealEd",
				"ToolMenus",
				"CoreUObject",
				"Engine",
				"Slate",
				"SlateCore",
				"AssetTools",
				"AssetRegistry",
				"EditorScriptingUtilities",
				"CoreUObject",
                "Niagara",
                "GSRuntime",

                "Media",
                "Blutility",
                "UMG",
                "Json",
                "LevelSequence",
                "MovieScene",
                "DesktopPlatform",
                "Eigen",
				// ... add private dependencies that you statically link with here ...	
			}
			);
		
		
		DynamicallyLoadedModuleNames.AddRange(
			new string[]
			{
				// ... add any modules that your module loads dynamically here ...
			}
			);
	}
}

// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;

public class GSRuntime : ModuleRules
{
	public GSRuntime(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = ModuleRules.PCHUsageMode.UseExplicitOrSharedPCHs;
        bUsePrecompiled = true;
        PublicIncludePaths.AddRange(
			new string[] {
				// ... add public include paths required here ...
			}
			);
				
			
		
		PublicDependencyModuleNames.AddRange(
			new string[]
			{
				"Core",
                "RHI",
                "RenderCore",
				// ... add other public dependencies that you statically link with here ...
			}
			);
			
		
		PrivateDependencyModuleNames.AddRange(
			new string[]
			{
				"CoreUObject",
				"Engine" ,
                "Niagara",
				"RenderCore",
				"RHI",
                "Projects",
            }
			);
		
		

		DynamicallyLoadedModuleNames.AddRange(
			new string[]
			{
				// ... add any modules that your module loads dynamically here ...
			}
			);

        if (Target.Type == TargetType.Editor)
        {
            PrivateDependencyModuleNames.AddRange(
            new string[]
            {
                    "UnrealEd",
                    "AssetTools",
					"AssetRegistry",
                    "EditorScriptingUtilities",
            });
        }
    }
}

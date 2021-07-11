// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "K2Node.h"

#include "EdGraph/EdGraphPin.h"
#include "Engine/Blueprint.h"
#include "Framework/Commands/UIAction.h"
#include "ToolMenus.h"
#include "EdGraphSchema_K2.h"
#include "EdGraph/EdGraphNodeUtils.h"
#include "Kismet2/BlueprintEditorUtils.h"

#include "ScopedTransaction.h"
#include "EdGraphUtilities.h"
#include "KismetCompiledFunctionContext.h"
#include "KismetCompilerMisc.h"
#include "BlueprintNodeSpawner.h"
#include "EditorCategoryUtils.h"
#include "BlueprintActionDatabaseRegistrar.h"

#include "K2Node_CallToLuaWithArgs.generated.h"

/**
 * 
 */
UCLASS()
class LUA_WRAPPER_API UK2Node_CallToLuaWithArgs : public UK2Node
{
	GENERATED_BODY()

public:
	// UEdGraphNode interface
	virtual FText GetTooltipText() const override { return FText::FromString(TEXT("Call lua function with types")); }
	virtual FText GetNodeTitle(ENodeTitleType::Type TitleType) const override { return FText::FromString(TEXT("CallToLuaWithArgsByTypes")); }
	// End of UEdGraphNode interface

	// UK2Node interface
	virtual FText GetMenuCategory() const { return FText::FromString(TEXT("SLuaExtensions")); }
	virtual void GetMenuActions(FBlueprintActionDatabaseRegistrar& ActionRegistrar) const override;
	// End of UK2Node interface
};

// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerState.h"
#include "GameFramework/GameState.h"
#include "Components/SceneComponent.h"
#include "AIController.h"
#include "LuaActor.h"
#include "LuaActorExtension.generated.h"


UCLASS()
class SLUAEXTENSION_API ALuaPlayerState : public APlayerState, public slua_Luabase, public ILuaTableObjectInterface {
	GENERATED_BODY()
		LUABASE_BODY(LuaPlayerState)
public:
	ALuaPlayerState(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get())
		: APlayerState(ObjectInitializer)
	{
		PrimaryActorTick.bCanEverTick = true;
		LUABASE_INIT_TABLE(LuaPlayerState)
	}
public:
	// below UPROPERTY and UFUNCTION can't be put to macro LUABASE_BODY
	// so copy & paste them
	UPROPERTY(BlueprintReadOnly, EditAnywhere, Category = "slua")
		FString LuaFilePath;
	UPROPERTY(BlueprintReadOnly, EditAnywhere, Category = "slua")
		FString LuaStateName;
	UFUNCTION(BlueprintCallable, Category = "slua")
		FLuaBPVar CallLuaMember(FString FunctionName, const TArray<FLuaBPVar>& Args) {
		return callMember(FunctionName, Args);
	}
};

UCLASS()
class SLUAEXTENSION_API ALuaGameState : public AGameStateBase, public slua_Luabase, public ILuaTableObjectInterface {
	GENERATED_BODY()
		LUABASE_BODY(LuaGameState)
public:
	ALuaGameState(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get())
		: AGameStateBase(ObjectInitializer)
	{
		PrimaryActorTick.bCanEverTick = true;
		LUABASE_INIT_TABLE(LuaGameState)
	}
public:
	// below UPROPERTY and UFUNCTION can't be put to macro LUABASE_BODY
	// so copy & paste them
	UPROPERTY(BlueprintReadOnly, EditAnywhere, Category = "slua")
		FString LuaFilePath;
	UPROPERTY(BlueprintReadOnly, EditAnywhere, Category = "slua")
		FString LuaStateName;
	UFUNCTION(BlueprintCallable, Category = "slua")
		FLuaBPVar CallLuaMember(FString FunctionName, const TArray<FLuaBPVar>& Args) {
		return callMember(FunctionName, Args);
	}
};


UCLASS(ClassGroup = (Custom), meta = (BlueprintSpawnableComponent))
class SLUAEXTENSION_API ULuaSceneComponent : public USceneComponent, public slua_Luabase, public ILuaTableObjectInterface {
	GENERATED_BODY()

		struct TickTmpArgs {
		float deltaTime;
		enum ELevelTick tickType;
		FActorComponentTickFunction* thisTickFunction;
	};
protected:
	virtual void BeginPlay() override {
		Super::BeginPlay();
		if (!GetClass()->HasAnyClassFlags(CLASS_CompiledFromBlueprint))
			ReceiveBeginPlay();
		if (luaSelfTable.isTable())
			PrimaryComponentTick.SetTickFunctionEnable(postInit("bCanEverTick"));
	}
	virtual void EndPlay(const EEndPlayReason::Type EndPlayReason) override {
		Super::EndPlay(EndPlayReason);
		if (!GetClass()->HasAnyClassFlags(CLASS_CompiledFromBlueprint))
			ReceiveEndPlay(EndPlayReason);
	}
	virtual void TickComponent(float DeltaTime, enum ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override {
		tickTmpArgs.deltaTime = DeltaTime;
		tickTmpArgs.tickType = TickType;
		tickTmpArgs.thisTickFunction = ThisTickFunction;
		if (!tickFunction.isValid()) {
			superTick();
			return;
		}
		tickFunction.call(luaSelfTable, DeltaTime);
	}
public:
	virtual void ProcessEvent(UFunction* func, void* params) override {
		if (luaImplemented(func, params))
			return;
		Super::ProcessEvent(func, params);
	}
	void superTick() override {
		Super::TickComponent(tickTmpArgs.deltaTime, tickTmpArgs.tickType, tickTmpArgs.thisTickFunction);
		if (!GetClass()->HasAnyClassFlags(CLASS_CompiledFromBlueprint))
			ReceiveTick(tickTmpArgs.deltaTime);
	}
	NS_SLUA::LuaVar getSelfTable() const {
		return luaSelfTable;
	}
public:
	ULuaSceneComponent(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get())
		: USceneComponent(ObjectInitializer)
	{
		PrimaryComponentTick.bCanEverTick = true;
		LUABASE_COMPONENT_INIT_TABLE(LuaSceneComponent)
	}
public:
	struct TickTmpArgs tickTmpArgs;
	// below UPROPERTY and UFUNCTION can't be put to macro LUABASE_BODY
	// so copy & paste them
	UPROPERTY(BlueprintReadWrite, EditAnywhere, Category = "slua")
		FString LuaFilePath;
	UPROPERTY(BlueprintReadWrite, EditAnywhere, Category = "slua")
		FString LuaStateName;
	UFUNCTION(BlueprintCallable, Category = "slua")
		FLuaBPVar CallLuaMember(FString FunctionName, const TArray<FLuaBPVar>& Args) {
		return callMember(FunctionName, Args);
	}

};

UCLASS()
class SLUAEXTENSION_API ALuaAIController : public AAIController, public slua_Luabase, public ILuaTableObjectInterface {
	GENERATED_BODY()
		LUABASE_BODY(LuaAIController)
public:
	ALuaAIController(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get())
		: AAIController(ObjectInitializer)
	{
		PrimaryActorTick.bCanEverTick = true;
		LUABASE_INIT_TABLE(LuaAIController)
	}
public:
	// below UPROPERTY and UFUNCTION can't be put to macro LUABASE_BODY
	// so copy & paste them
	UPROPERTY(BlueprintReadOnly, EditAnywhere, Category = "slua")
		FString LuaFilePath;
	UPROPERTY(BlueprintReadOnly, EditAnywhere, Category = "slua")
		FString LuaStateName;
	UFUNCTION(BlueprintCallable, Category = "slua")
		FLuaBPVar CallLuaMember(FString FunctionName, const TArray<FLuaBPVar>& Args) {
		return callMember(FunctionName, Args);
	}
};
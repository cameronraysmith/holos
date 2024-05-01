// @generated by protoc-gen-connect-query v1.3.1 with parameter "target=ts"
// @generated from file holos/v1alpha1/platform.proto (package holos.v1alpha1, syntax proto3)
/* eslint-disable */
// @ts-nocheck

import { MethodKind } from "@bufbuild/protobuf";
import { AddPlatformRequest, GetPlatformRequest, GetPlatformResponse, GetPlatformsRequest, GetPlatformsResponse, PutPlatformConfigRequest } from "./platform_pb.js";

/**
 * @generated from rpc holos.v1alpha1.PlatformService.AddPlatform
 */
export const addPlatform = {
  localName: "addPlatform",
  name: "AddPlatform",
  kind: MethodKind.Unary,
  I: AddPlatformRequest,
  O: GetPlatformsResponse,
  service: {
    typeName: "holos.v1alpha1.PlatformService"
  }
} as const;

/**
 * @generated from rpc holos.v1alpha1.PlatformService.GetPlatforms
 */
export const getPlatforms = {
  localName: "getPlatforms",
  name: "GetPlatforms",
  kind: MethodKind.Unary,
  I: GetPlatformsRequest,
  O: GetPlatformsResponse,
  service: {
    typeName: "holos.v1alpha1.PlatformService"
  }
} as const;

/**
 * @generated from rpc holos.v1alpha1.PlatformService.GetPlatform
 */
export const getPlatform = {
  localName: "getPlatform",
  name: "GetPlatform",
  kind: MethodKind.Unary,
  I: GetPlatformRequest,
  O: GetPlatformResponse,
  service: {
    typeName: "holos.v1alpha1.PlatformService"
  }
} as const;

/**
 * @generated from rpc holos.v1alpha1.PlatformService.PutPlatformConfig
 */
export const putPlatformConfig = {
  localName: "putPlatformConfig",
  name: "PutPlatformConfig",
  kind: MethodKind.Unary,
  I: PutPlatformConfigRequest,
  O: GetPlatformResponse,
  service: {
    typeName: "holos.v1alpha1.PlatformService"
  }
} as const;

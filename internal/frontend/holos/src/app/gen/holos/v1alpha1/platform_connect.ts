// @generated by protoc-gen-connect-es v1.4.0 with parameter "target=ts"
// @generated from file holos/v1alpha1/platform.proto (package holos.v1alpha1, syntax proto3)
/* eslint-disable */
// @ts-nocheck

import { AddPlatformRequest, GetPlatformRequest, GetPlatformResponse, GetPlatformsRequest, GetPlatformsResponse } from "./platform_pb.js";
import { MethodKind } from "@bufbuild/protobuf";

/**
 * @generated from service holos.v1alpha1.PlatformService
 */
export const PlatformService = {
  typeName: "holos.v1alpha1.PlatformService",
  methods: {
    /**
     * @generated from rpc holos.v1alpha1.PlatformService.GetPlatforms
     */
    getPlatforms: {
      name: "GetPlatforms",
      I: GetPlatformsRequest,
      O: GetPlatformsResponse,
      kind: MethodKind.Unary,
    },
    /**
     * @generated from rpc holos.v1alpha1.PlatformService.AddPlatform
     */
    addPlatform: {
      name: "AddPlatform",
      I: AddPlatformRequest,
      O: GetPlatformsResponse,
      kind: MethodKind.Unary,
    },
    /**
     * @generated from rpc holos.v1alpha1.PlatformService.GetPlatform
     */
    getPlatform: {
      name: "GetPlatform",
      I: GetPlatformRequest,
      O: GetPlatformResponse,
      kind: MethodKind.Unary,
    },
  }
} as const;


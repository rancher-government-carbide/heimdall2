import { Injectable } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import e, { Request } from "express";
import { Strategy } from "passport-jwt";
import { KubernetesService } from "./kubernetes.service";

@Injectable()
export class KubernetesStrategy extends PassportStrategy(Strategy, 'rancher') {
  constructor (private kubernetesService: KubernetesService) {
    super();
  }

  async validate(req: Request): Promise<any> {
    const token = req.headers['Authorization'] || "";

    let allowed = await this.kubernetesService.checkK8sPerms(token)

    return true
  }
}
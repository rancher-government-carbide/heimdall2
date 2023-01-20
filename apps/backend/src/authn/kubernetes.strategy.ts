import { Injectable } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import e, { Request } from "express";
import { Strategy } from "passport-local";
import { KubernetesService } from "./kubernetes.service";

@Injectable()
export class KubernetesStrategy extends PassportStrategy(Strategy, 'kubernetes') {
  constructor (private kubernetesService: KubernetesService) {
    super();
  }

  async validate(req: Request): Promise<any> {
    const token = req.headers['Authorization'] || "";

    let allowed = await this.kubernetesService.checkK8sPerms(token)

    return allowed
  }
}

// if this isn't working, consider implementing the check in the super() call as found in apikey.strategy.ts
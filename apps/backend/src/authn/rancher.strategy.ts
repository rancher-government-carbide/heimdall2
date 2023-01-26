import { Injectable, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { Strategy } from 'passport-cookie';
import { User } from "src/users/user.model";
import { AuthnService } from "./authn.service";
import { KubernetesService } from "./kubernetes.service";
import { RancherService } from "./rancher.service";

@Injectable()
export class RancherStrategy extends PassportStrategy(Strategy, 'rancher')  {
  constructor(
    k8sService: KubernetesService,
    rancherService: RancherService,
    authnService: AuthnService
  ){
    super({
      cookieName: 'R_SESS'
    },
      async function(token: string, done: any) {
      try {
        let _ = await k8sService.checkK8sPerms(token)

        // auth is good. now, grab user's information
        
        let rancherUser = await rancherService.getUser(token)
        
        let heimdallUser = await authnService.validateOrCreateUser(rancherUser.id + '@rancher.local', rancherUser.name, "Rancher User", 'rancher')

        return done(null, heimdallUser);
      } catch (err) {
        return done(err, false);
      }
    }
    );
  }
}
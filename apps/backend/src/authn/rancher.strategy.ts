import { Injectable, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { Strategy } from 'passport-cookie';
import { AuthnService } from "./authn.service";
import { KubernetesService } from "./kubernetes.service";
import { RancherService } from "./rancher.service";
import { GroupsService } from '../groups/groups.service';
import { Group } from "src/groups/group.model";

@Injectable()
export class RancherStrategy extends PassportStrategy(Strategy, 'rancher')  {
  constructor(
    k8sService: KubernetesService,
    rancherService: RancherService,
    groupsService: GroupsService,
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

        // once user has been created, associate them with default rancher group

        let group = await (await groupsService.findAll()).filter((g: Group) => {
          return g.name == 'rancher'
        })[0];

        // map
        await groupsService.addUserToGroup(group, heimdallUser, 'member');

        return done(null, heimdallUser);
      } catch (err) {
        return done(err, false);
      }
    }
    );
  }
}
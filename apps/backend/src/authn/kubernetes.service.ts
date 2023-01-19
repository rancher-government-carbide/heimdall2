import { Injectable } from "@nestjs/common";
import { ConfigService } from '../config/config.service';
import axios, { all, AxiosInstance, AxiosResponse } from 'axios';
import https from 'https';

interface K8sObject {
  apiVersion: string;
  kind: string;
  metadata: {
    creationTimestamp: null
  }
}

class SelfSubjectAccessReview implements K8sObject {
  apiVersion!: 'authorization.k8s.io/v1'
  kind!: 'SelfSubjectAccessReview'
  metadata!: {
    creationTimestamp: null
  }
  spec: {
    resourceAttributes: ResourceAttributes;
  }
  status!: {
    allowed: boolean;
    denied: boolean;
  }

  constructor(ra: ResourceAttributes) {
    this.spec = {
      resourceAttributes: ra
    }
  }
}

interface ResourceAttributes {
  group: string;
  resource: string;
  namespace: string;
  verb: string;
}

// sample
// K8S_PERMS=group,resource,namespace,verb;group,resource,namespace,verb
// K8S_PERMS=compliance.cattle.io,scans,,list;apps,deployments,default,create

@Injectable()
export class KubernetesService {
  private perms: ResourceAttributes[];
  private httpClient: AxiosInstance
  
  constructor(
    private configService: ConfigService
  ){
    let perms = configService.get('K8S_PERMS') || "";

    this.perms = this._parsePerms(perms)

    this.httpClient = axios.create({
      responseType: 'json',
      httpsAgent: new https.Agent({
        rejectUnauthorized: false
      })
    })
  }

  public async checkK8sPerms(token: string | string[]) : Promise<string> {
    // for each k8s perm check if it is allowed or not
    let err = "";
    
    this.perms.forEach((ra: ResourceAttributes) => {
      this.httpClient({
        method: 'post',
        url: 'https://localhost:8001/apis/authorization.k8s.io/v1/selfsubjectaccessreviews',
        headers: {
          'Authorization': 'Bearer ' + token,
          'Accepts': 'json'
        },
        data: new SelfSubjectAccessReview(ra)
      }).then((res: AxiosResponse) => {
        let ssar = res.data as SelfSubjectAccessReview

        if (!ssar.status.allowed) {
          err = "Permission denied"
        }
      }).catch((e: any) => {
        err = e
      })
    })

    return err
  }

  private _parsePerms(permString: string) : ResourceAttributes[] {
    // split each by ;
    let permArr = permString.split(';')
    // for each in perm arr, split and create the resourceattributes
    let out = [] as ResourceAttributes[];
    permArr.forEach((p: string) => {
      let pA = p.split(',')
      out.push({
        group: pA[0],
        resource: pA[1],
        namespace: pA[2],
        verb: pA[3],
      })
    })

    return out
  }
}
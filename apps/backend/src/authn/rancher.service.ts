import { Injectable } from "@nestjs/common";

@Injectable()
export class RancherService {
  async validateUser(token: string): Promise<any> {
    // attempt to retrieve scans from cluster
    
  }
}
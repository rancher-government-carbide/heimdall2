import { Injectable } from "@nestjs/common";
import axios, { Axios, AxiosInstance } from 'axios';
import https from 'https';
import { ConfigService } from "src/config/config.service";

class NormanUser {
  annotations?: Map<string, string>;
  created!: string;
  id!: string;
  labels?: Map<string, string>;
  name!: string;
  uuid!: string;
}

@Injectable()
export class RancherService {
  private httpClient: AxiosInstance;

  constructor(
    private configService: ConfigService
  ){
    this.httpClient = axios.create({
      responseType: 'json',
      httpsAgent: new https.Agent({
        rejectUnauthorized: false
      })
    })
  }

  async getUser(token: string): Promise<NormanUser> {
    try {
      let res = await this.httpClient({
        method: 'get',
        url: this.configService.get('RANCHER_URL') + '/v3/users?me=true',
        headers: {
          'Authorization': 'Bearer ' + token,
          'Accepts': 'json'
        }
      })

      return res.data.data[0]
    } catch (e: any) {
      throw new Error(e)
    }
  }
}

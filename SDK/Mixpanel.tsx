import { Mixpanel } from "mixpanel-react-native";
import { getUniqueId } from 'react-native-device-info';

let instance;

class MixpanelSDk {
  private mixpanel: Mixpanel; 
  constructor() {
    if (instance) {
      throw new Error('You can only create one instance!');
    }
    instance = this;
  }

  async init() {
    const trackAutomaticEvents = false;
    this.mixpanel = new Mixpanel("db86127b20da494d72aba1bbdc3d934c", trackAutomaticEvents);
    await this.mixpanel.init();
    const uniqueId = await getUniqueId();
    this.mixpanel.identify(uniqueId)
  }

  trackEvent(eventName: string, properties: object = {}) {
    if (this.mixpanel) {
      this.mixpanel.track(eventName, properties);
    } else {
      console.error('Mixpanel is not initialized.');
    }
  }
}

const MixpanelService = new MixpanelSDk();
export { MixpanelService };
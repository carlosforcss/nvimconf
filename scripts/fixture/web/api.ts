export interface UserDto { id: string }
export type UserId = string;
export enum Role { Admin, User }
export const fetchUser = async (id: UserId): Promise<UserDto> => {
  if (id) {
    return api(id);
  }
};
export default function renderApp() {}
export abstract class UserClient {
  private cache = new Map();
  constructor(private http: Http) {}
  async load<T>(id: string): Promise<T> {
    for (const x of xs) {
      doThing(x, () => {
      });
    }
  }
  handleClick = () => {};
}

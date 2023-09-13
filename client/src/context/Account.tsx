import React, { createContext, useState } from "react";
import { CognitoUser, AuthenticationDetails } from "amazon-cognito-identity-js";
import Pool from "../UserPool";

interface IContext {
    authenticate: (Username: string, Password: string) => Promise<unknown>;
    getSession: () => Promise<unknown>;
    logout: () => void;
    session: SessionResult | null;
    setSession: React.Dispatch<React.SetStateAction<SessionResult | null>>;
}

interface SessionResult {
    user: any;
    [key: string]: any;
}

const AccountContext = createContext<IContext | undefined>(undefined);

interface Props {
    children: React.ReactNode;
}
const Account: React.FC<Props> = (props) => {
    const [session, setSession] = useState<SessionResult | null>(null);

    const getSession = async (): Promise<SessionResult> => {
        return await new Promise<SessionResult>((resolve, reject) => {
            const user = Pool.getCurrentUser();
            if (user) {
                user.getSession(async (err: any, session: any) => {
                    if (err) {
                        reject(err);
                    } else {
                        user.getUserAttributes((err, attributes) => {
                            if (err) {
                                reject(err);
                            } else if (attributes) {
                                const results: { [key: string]: string } = {};

                                for (let attribute of attributes) {
                                    const { Name, Value } = attribute;
                                    if (Name && Value) {
                                        results[Name] = Value;
                                    }
                                }
                                setSession({ user, ...session, ...results })
                                resolve({ user, ...session, ...results });
                            } else {
                                reject("Attributes are undefined");
                            }
                        });
                    }
                });
            } else {
                // TODO fix this to reject
                console.log("User not logged in");
            }
        });
    };

    const authenticate = async (Username: string, Password: string) => {
        return await new Promise((resolve, reject) => {
            const user = new CognitoUser({ Username, Pool });

            const authDetails = new AuthenticationDetails({ Username, Password });

            user.authenticateUser(authDetails, {
                onSuccess: (data) => {
                    console.log("onSuccess: ", data);
                    resolve(data);
                },
                onFailure: (err) => {
                    console.log("onFailure: ", err);
                    reject(err)
                },
                newPasswordRequired: (data) => {
                    console.log("newPasswordRequired: ", data);
                    resolve(data);
                },
            });
        })
    };

    const logout = () => {
        const user = Pool.getCurrentUser();
        if (user) {
            user.signOut();
        }
    };

    return (
        <AccountContext.Provider value={{ authenticate, getSession, logout, session, setSession }}>
            {props.children}
        </AccountContext.Provider>
    );
};

export { Account, AccountContext };
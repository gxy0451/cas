/*
 * Licensed to Apereo under one or more contributor license
 * agreements. See the NOTICE file distributed with this work
 * for additional information regarding copyright ownership.
 * Apereo licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License.  You may obtain a
 * copy of the License at the following location:
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.jasig.cas.authentication;

import org.jasig.cas.authentication.handler.support.AbstractUsernamePasswordAuthenticationHandler;
import org.jasig.cas.authentication.principal.SimplePrincipal;

import javax.naming.Context;
import javax.naming.directory.DirContext;
import javax.naming.directory.InitialDirContext;
import javax.security.auth.login.FailedLoginException;
import java.security.GeneralSecurityException;
import java.util.Hashtable;

/**
 * 自定义验证方式，通过ldap链接AD服务器验证用户名密码
 * @author Lewis Gao
 * @since 4.0.1
 */
public class CustomUsersAuthenticationHandler extends AbstractUsernamePasswordAuthenticationHandler {
    /**
     * AD服务器IP
     */
    private String adHost;

    /**
     * AD服务器端口号
     */
    private String port;

    /**
     * {@inheritDoc}
     */
    @Override
    protected final HandlerResult authenticateUsernamePasswordInternal(final UsernamePasswordCredential credential)
            throws GeneralSecurityException, PreventedException {

        final String username = credential.getUsername();
        final String password = credential.getPassword();

        if (!check(username, password)) {
            throw new FailedLoginException();
        }
        return createHandlerResult(credential, new SimplePrincipal(username), null);
    }

    public boolean check(String userName, String password) {
//        String DN_OU = "OU=Capitaland China,OU=CCH,DC=capitaland,DC=com,DC=cn";
//        String DN_CN = "CN=" + userName;

        String url = "ldap://" + adHost + ":" + port;

        Hashtable env = new Hashtable();
        DirContext ctx;
        env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
        //env.put(Context.SECURITY_AUTHENTICATION, "none");
        env.put(Context.SECURITY_AUTHENTICATION, "simple");
        env.put(Context.PROVIDER_URL, url);
        //env.put(Context.SECURITY_PRINCIPAL, DN_CN+","+DN_OU);
        env.put(Context.SECURITY_PRINCIPAL, userName);
        env.put(Context.SECURITY_CREDENTIALS, password);

        try {
            ctx = new InitialDirContext(env);// 初始化上下文
            System.out.println("认证成功");
            ctx.close();
            return true; //验证成功返回name
        } catch (javax.naming.AuthenticationException e) {
            System.out.println("认证失败");
            return false;
        } catch (Exception e) {
            System.out.println("认证出错：" + e);
            return false;
        }
    }

    public String getAdHost() {
        return adHost;
    }

    public void setAdHost(String adHost) {
        this.adHost = adHost;
    }

    public String getPort() {
        return port;
    }

    public void setPort(String port) {
        this.port = port;
    }
}

# Central Authentication Service (CAS)

项目地址：<http://www.jasig.org/cas>

github地址：<https://github.com/Jasig/cas>

本项目为原项目的副本，基于4.0.1调整。

##在4.0.1上做了如下调整项：

###1调整登录验证方式
增加`org.jasig.cas.authentication.CustomUsersAuthenticationHandler`
将cas-server-webapp\src\main\webapp\WEB-INF\deployerConfigContext.xml中的bean：primaryAuthenticationHandler调整为CustomUsersAuthenticationHandler

###2去掉cas必须为https限制
- 将`cas-server-webapp\src\main\webapp\WEB-INF\spring-configuration\ticketGrantingTicketCookieGenerator.xml`中
bean：ticketGrantingTicketCookieGenerator 的cookieSecure属性改为false
- 将`cas-server-webapp\src\main\webapp\WEB-INF\spring-configuration\warnCookieGenerator.xml`中
bean：warnCookieGenerator 的cookieSecure属性改为false
- 在`cas-server-webapp\src\main\webapp\WEB-INF\deployerConfigContext.xml`中
bean：proxyAuthenticationHandler 增加属性p:requireSecure="false"

###3开启注销时的自动跳转（否则注销会停留在cas的成功页）
调整`cas-server-webapp\src\main\webapp\WEB-INF\cas.properties`中cas.logout.followServiceRedirects选项为true

##编译war
本项目中的cas-server-webapp模块即可生成最终的war。去掉最外层pom中的checkstyle插件和license插件，
在cas-server-webapp下运行mvn clean package即可。

##客户端使用(以clover工程为例)

###1增加`com.infitecs.clover.core.security.shirorealm.ShiroCasRealm.java`
        package com.infitecs.clover.core.security.shirorealm;
        
        import com.infitecs.clover.core.security.model.Role;
        import com.infitecs.clover.core.security.service.UserService;
        import org.apache.shiro.authz.AuthorizationInfo;
        import org.apache.shiro.authz.SimpleAuthorizationInfo;
        import org.apache.shiro.cas.CasRealm;
        import org.apache.shiro.subject.PrincipalCollection;
        import org.springframework.beans.factory.annotation.Autowired;
        
        import java.util.List;
        
        public class ShiroCasRealm extends CasRealm {
        
            private UserService userService;
        
            @Autowired
            public void setUserService(UserService userService) {
                this.userService = userService;
            }
        
            @Override
            protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
                String username = (String) getAvailablePrincipal(principals); // 使用Shiro提供的方法获取用户名称
                if (username != null) {
                    SimpleAuthorizationInfo info = new SimpleAuthorizationInfo();
                    List<Role> roles = userService.getRolesByUsername(username);
                    if (roles != null) {
                        // 加入用户角色
                        for (Role role : roles) {
                            info.addRole(role.getRoleName());
                        }
                    }
                    List<String> permTokens = userService.getPermTokensByUsername(username);
                    if (permTokens != null) {
                        // 加入用户许可标记
                        info.addStringPermissions(permTokens);
                    }
                    return info;
                }
                return null;
            }
        
        }

###2增加`com.infitecs.clover.core.security.filter.CustomCasFilter`
        package com.infitecs.clover.core.security.filter;
        
        import com.infitecs.clover.core.develop.service.MenuService;
        import com.infitecs.clover.core.security.model.User;
        import com.infitecs.clover.core.security.service.UserService;
        import com.infitecs.clover.util.HttpSessionUtil;
        import org.apache.shiro.authc.AuthenticationToken;
        import org.apache.shiro.cas.CasFilter;
        import org.apache.shiro.subject.Subject;
        import org.springframework.beans.factory.annotation.Autowired;
        
        import javax.servlet.ServletRequest;
        import javax.servlet.ServletResponse;
        import javax.servlet.http.HttpServletRequest;
        
        /**
         * 自定义cas过滤器，在cas验证成功后获取username并对session数据及菜单进行初始化
         */
        public class CustomCasFilter extends CasFilter {
        
            @Autowired
            private MenuService menuService;
        
            @Autowired
            private UserService userService;
        
            @Override
            protected boolean onLoginSuccess(AuthenticationToken token, Subject subject, ServletRequest request, ServletResponse response) throws Exception {
                User loginUser = userService.getUserByUsername(token.getPrincipal().toString());
                HttpSessionUtil.saveUserToSession(loginUser, (HttpServletRequest)request);
                menuService.updateMenuInHttpSession((HttpServletRequest)request);
                return super.onLoginSuccess(token, subject, request, response);
            }
        }

###3增加`clover-webapp\src\main\webapp\WEB-INF\jsp\core\error\casfailure.jsp`
        <%@ page contentType="text/html;charset=UTF-8" language="java" %>
        <!DOCTYPE html>
        <!--[if IE 8]> <html lang="en" class="ie8 no-js"> <![endif]-->
        <!--[if IE 9]> <html lang="en" class="ie9 no-js"> <![endif]-->
        <!--[if !IE]><!-->
        <html lang="en">
        <!--<![endif]-->
        <head>
            <title>CAS Failure</title>
            <%@include file="../includes/head.jsp"%>
            <link href="<c:url value="/assets/admin/pages/css/error.css"/>" rel="stylesheet" type="text/css"/>
        </head>
        <body class="page-header-fixed page-quick-sidebar-over-content">
        <%@include file="../includes/top.jsp"%>
        <div class="page-container">
            <%@include file="../includes/sidebar.jsp"%>
            <div class="page-content-wrapper">
                <div class="page-content">
                    <h3 class="page-title">
                        CAS Failure
                    </h3>
                    <div class="page-bar">
                        <ul class="page-breadcrumb">
                            <li>
                                <i class="fa fa-home"></i>
                                <a href="<c:url value="/"/>">主页</a>
                                <i class="fa fa-angle-right"></i>
                            </li>
                            <li>
                                <span>CAS Failure</span>
                            </li>
                        </ul>
                    </div>
                    <div class="row">
                        <div class="col-md-12 page-404">
                            <div class=" number">
                                Failure
                            </div>
                            <div class=" details">
                                <h3>Oops! CAS Failure！</h3>
                                <p>
                                    请联系管理员,<br/>
                                    或更改访问地址重试。<br/><br/>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%@include file="../includes/footer.jsp"%>
        <%@include file="../includes/bottomscript.jsp"%>
        </body>
        </html>
###4在`clover-webapp\src\main\resources\spring-mvc.xml`中增加：
        <mvc:view-controller path="/casFailure" view-name="core/error/casfailure"/>
###5在`clover-webapp\src\main\resources\application.properties`中增加：
        sso.casServer=http://localhost:8080/cas
        sso.clientServer=http://localhost:8083/clover
###6将`clover-webapp\src\main\resources\conf\applicationContext-shiro.xml`调整为如下：
        <?xml version="1.0" encoding="UTF-8"?>
        <beans xmlns="http://www.springframework.org/schema/beans"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:util="http://www.springframework.org/schema/util"
               xsi:schemaLocation="http://www.springframework.org/schema/beans
               http://www.springframework.org/schema/beans/spring-beans-4.1.xsd
               http://www.springframework.org/schema/util http://www.springframework.org/schema/util/spring-util.xsd"
               default-lazy-init="true">
        
            <description>Shiro安全配置</description>
        
            <!-- Shiro's main business-tier object for web-enabled applications -->
            <bean id="securityManager" class="org.apache.shiro.web.mgt.DefaultWebSecurityManager">
                <property name="realm" ref="shiroDbRealm"/>
                <property name="cacheManager" ref="shiroEhcacheManager"/>
            </bean>
            <!-- 項目自定义的Realm -->
            <!--独立验证Realm-->
            <!--<bean id="shiroDbRealm" class="com.infitecs.clover.core.security.shirorealm.ShiroDbRealm" depends-on="userDao,roleDao">-->
                <!--<property name="userService" ref="userService"/>-->
            <!--</bean>-->
            <!--单点登录验证Realm-->
            <bean id="shiroDbRealm" class="com.infitecs.clover.core.security.shirorealm.ShiroCasRealm" depends-on="userDao,roleDao">
                <property name="userService" ref="userService"/>
                <property name="casServerUrlPrefix" value="${sso.casServer}"/>
                <property name="casService" value="${sso.clientServer}/cas"/>
            </bean>
        
            <!--单点登录配置 begin-->
            <bean id="casFilter" class="com.infitecs.clover.core.security.filter.CustomCasFilter">
                <property name="failureUrl" value="/casFailure"/>
            </bean>
            <bean id="logout" class="org.apache.shiro.web.filter.authc.LogoutFilter">
                <property name="redirectUrl" value="${sso.casServer}/logout?service=${sso.clientServer}/"/>
            </bean>
            <!--单点登录配置 end-->
        
            <!-- Shiro Filter -->
            <bean id="shiroFilter" class="org.apache.shiro.spring.web.ShiroFilterFactoryBean">
                <property name="securityManager" ref="securityManager"/>
                <!--单点登录配置 begin-->
                <property name="loginUrl" value="${sso.casServer}/login?service=${sso.clientServer}/cas"/>
                <property name="filters">
                    <util:map>
                        <entry key="cas" value-ref="casFilter"/>
                        <entry key="logout" value-ref="logout"/>
                    </util:map>
                </property>
                <!--单点登录配置 end-->
                <property name="filterChainDefinitions">
                    <value>
                        /casFailure = anon
                        /cas = cas
                        /assets/** = anon
                        /css/** = anon
                        /img/** = anon
                        /js/** = anon
                        /login = anon
                        /login/captcha = anon
                        /logout = logout
                        /** = user
                    </value>
                </property>
            </bean>
        
            <!-- 用户授权信息Cache, 采用EhCache -->
            <bean id="shiroEhcacheManager" class="org.apache.shiro.cache.ehcache.EhCacheManager">
                <property name="cacheManagerConfigFile" value="classpath:conf/ehcache-shiro.xml"/>
            </bean>
        
            <!-- 保证实现了Shiro内部lifecycle函数的bean执行 -->
            <bean id="lifecycleBeanPostProcessor" class="org.apache.shiro.spring.LifecycleBeanPostProcessor"/>
        </beans>


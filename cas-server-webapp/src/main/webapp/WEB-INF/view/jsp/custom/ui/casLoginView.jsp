<%--@elvariable id="message" type="java.lang.String"--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<!--[if IE 8]> <html lang="en" class="ie8 no-js"> <![endif]-->
<!--[if IE 9]> <html lang="en" class="ie9 no-js"> <![endif]-->
<!--[if !IE]><!-->
<html lang="en">
<!--<![endif]-->
<head>
    <title>InfiTecs</title>
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8">
    <meta content="" name="description"/>
    <meta content="" name="author"/>
    <link href="http://libs.baidu.com/fontawesome/4.0.3/css/font-awesome.min.css" rel="stylesheet">
    <link href="http://libs.baidu.com/bootstrap/3.0.3/css/bootstrap.min.css" rel="stylesheet">
    <link href="<c:url value="/custom/assets/global/css/components.css"/>" rel="stylesheet" type="text/css"/>
    <link href="<c:url value="/custom/assets/admin/layout/css/layout.css"/>" rel="stylesheet" type="text/css"/>
    <%--<link rel="shortcut icon" href="favicon.ico"/>--%>
    <link href="<c:url value="/custom/assets/admin/pages/css/login-soft.css"/>" rel="stylesheet" type="text/css"/>
</head>
<body class="login">
<div class="logo">
    <a href="<c:url value="/login"/>">
        <img src="<c:url value="/custom/img/logo-big.png"/>" alt="" style="height:50px"/>
    </a>
</div>
<div class="menu-toggler sidebar-toggler">
</div>
<div class="content">
    <!-- BEGIN LOGIN FORM -->
    <form:form method="post" id="login-form" commandName="${commandName}" htmlEscape="true" cssClass="login-form">

        <input type="hidden" name="locale" value="en"/>

        <h3 class="form-title">Login to your account</h3>

        <form:errors path="*" id="msg" cssClass="alert alert-danger" element="div" htmlEscape="false" />

        <div class="alert alert-danger display-hide">
            <button class="close" data-close="alert"></button>
            <span>Enter any username and password.</span>
        </div>
        <div class="form-group" style="margin-bottom: 20px;">
            <label class="control-label visible-ie8 visible-ie9">Username</label>

            <div class="input-icon">
                <i class="fa fa-user"></i>
                <c:choose>
                  <c:when test="${not empty sessionScope.openIdLocalId}">
                    <strong>${sessionScope.openIdLocalId}</strong>
                    <input type="hidden" id="username" name="username" value="${sessionScope.openIdLocalId}" />
                  </c:when>
                  <c:otherwise>
                    <spring:message code="screen.welcome.label.netid.accesskey" var="userNameAccessKey" />
                    <form:input cssClass="form-control placeholder-no-fix" cssErrorClass="error" placeholder="Username"
                                id="username" value="lewis.gao@infitecs.com" size="25" tabindex="1" accesskey="${userNameAccessKey}" path="username" autocomplete="off" htmlEscape="true" />
                  </c:otherwise>
                </c:choose>
            </div>
        </div>
        <div class="form-group" style="margin-bottom: 20px;">
            <label class="control-label visible-ie8 visible-ie9">Password</label>

            <div class="input-icon">
                <i class="fa fa-lock"></i>
                <form:password cssClass="form-control placeholder-no-fix" cssErrorClass="error" placeholder="Password" id="password"
                               value="qwe!@#QWE" size="25" tabindex="2" path="password"  accesskey="${passwordAccessKey}" htmlEscape="true" autocomplete="off" />
            </div>
        </div>
        <div class="form-actions" style="padding-bottom: 50px;">
            <button type="button" id="loginBtn" class="btn blue pull-right">Login <i
                    class="m-icon-swapright m-icon-white"></i>
            </button>
        </div>
        <input type="hidden" name="lt" value="${loginTicket}" />
        <input type="hidden" name="execution" value="${flowExecutionKey}" />
        <input type="hidden" name="_eventId" value="submit" />
    </form:form>
    <!-- END LOGIN FORM -->
</div>
<div class="copyright">
    Copyright @ 2014-2015 InfiTecs Technology Co., Ltd
</div>
<!-- BEGIN CORE PLUGINS -->

<script src="http://libs.baidu.com/jquery/1.10.2/jquery.min.js"></script>
<script src="http://libs.baidu.com/bootstrap/3.0.3/js/bootstrap.min.js"></script>
<script src="<c:url value="/custom/js/jquery-validation/dist/jquery.validate.min.js"/>" type="text/javascript"></script>
<script src="<c:url value="/custom/js/metronic.js"/>" type="text/javascript"></script>
<script src="<c:url value="/custom/assets/admin/layout/scripts/layout.js"/>" type="text/javascript"></script>
<script src="<c:url value="/custom/js/jquery-backstretch/jquery.backstretch.min.js"/>" type="text/javascript"></script>
<script src="<c:url value="/custom/js/login.js"/>" type="text/javascript"></script>
<spring:theme code="cas.javascript.file" var="casJavascriptFile" text="" />
<script type="text/javascript" src="<c:url value="${casJavascriptFile}" />"></script>

<script>
    $(function () {
        $.validator.setDefaults({
            errorElement: 'span', //default input error message container
            errorClass: 'help-block help-block-error', // default input error message class
            focusInvalid: true,
            ignore: "",  // validate all fields including form hidden input
            highlight: function (element) { // hightlight error inputs
                $(element).closest('.form-group').addClass('has-error'); // set error class to the control group
            },
            unhighlight: function (element) { // revert the change done by hightlight
                $(element).closest('.form-group').removeClass('has-error'); // set error class to the control group
            },
            success: function (label) {
                label.closest('.form-group').removeClass('has-error'); // set success class to the control group
            },
            invalidHandler: function (event, validator) { //display error alert on form submit
                toastr.error(i18n["tableWrong"]);
            }
        });
        Metronic.init(); // init metronic core components
        Layout.init(); // init current layout
        Login.init();
    })
</script>
</body>
</html>

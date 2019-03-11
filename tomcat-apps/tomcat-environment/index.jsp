<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
    <title>Tomcat environment</title>
    </head>
    <body>
        <header>
            <h1>Tomcat environment</h1>
            <p>This page gives basic information about the Tomcat/Server environment provided by the 
                <a href="https://tomcat.apache.org/tomcat-8.5-doc/servletapi/javax/servlet/http/HttpServletRequest.html"><code>HttpServletRequest</code></a>
                object.</p>
        </header>
        <section>
            <h2><code>request.getRequestURI()</code></h2>
            <pre><%= request.getRequestURI() %></pre>
        </section>
        <section>
            <h2>Full URL</h2>
<pre>
<%= request.getScheme() + "://" + request.getServerName() + request.getServerPort() + request.getRequestURI() + (request.getQueryString() != null ? "?" + request.getQueryString() : "")
%>
</pre>
        </section>
        <section>
            <h2><code>X-Forwarded-Proto</code> header value</h2>
            <pre><%= request.getHeader("x-forwarded-proto") %></pre>
        </section>
        <section>
            <h2><code>request.isSecure()</code></h2>
            <pre><%= request.isSecure() %></pre>
        </section>
    </body>
</html>

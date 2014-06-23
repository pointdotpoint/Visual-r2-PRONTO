<%@ include file="/commons/taglibs.jsp"%>
<!doctype html>
<html lang="pt-br">
    <head>
        <title>Pronto Agile | <decorator:title/></title>
		<%@ include file="/commons/themes/styles.jsp"%>
        <%@ include file="/commons/scripts/scripts.jsp"%>
        <decorator:head/>
    </head>
	<body<decorator:getProperty property="body.id" writeEntireProperty="true"/><decorator:getProperty property="body.class" writeEntireProperty="true"/>>
	    <div id="page">
	        <div id="header" class="clearfix">
	            <jsp:include page="/commons/header.jsp"/>
	        </div>
	        
	        <div id="content" class="clearfix">
	            <c:if test="${mensagem ne null || param.mensagem ne null}">
	            	<br>
					<div class="ui-widget"> 
						<div class="ui-state-highlight ui-corner-all" style="padding-left: 10px;"> 
							<p><br><span class="ui-icon ui-icon-info" style="float: left;"> </span> 
							&nbsp; ${mensagem}${param.mensagem}</p> 
						</div> 
					</div>
	            </c:if>
					            
	            <c:if test="${erro ne null || param.erro ne null}">
					<br>
					<div class="ui-widget">
						<div class="ui-state-error ui-corner-all" style="padding-left: 10px;">
							<p><br><span class="ui-icon ui-icon-alert" style="float: left;"> </span>
							&nbsp; ${erro}${param.erro}</p>
						</div>
					</div>
	            </c:if>
	            
	            <div id="main">
	                <h1><decorator:getProperty property="page.heading"/></h1>
	                <decorator:body/>
	            </div>
	            <c:set var="currentMenu" scope="request"><decorator:getProperty property="meta.menu"/></c:set>
	        </div>

	        <div id="footer" class="clearfix">
	            <jsp:include page="/commons/footer.jsp"/>
	        </div>
	    </div>
	</body>
</html>
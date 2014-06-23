<%@ include file="/commons/taglibs.jsp"%>
<html>
	<head>
		<title>Cadastro de M�dulos</title>
		<script>
			$(function() {
				$('#formModulo').validate();
			});
		</script>
	</head>
	<body>
		<form action="${raiz}modulos/" id="formModulo" method="post">

			<ul class="info">
				<h1>Cadastro de M�dulos</h1>
			</ul>
			<div class="group">
				<form:hidden path="modulo.moduloKey"/>
				<c:if test="${modulo.moduloKey gt 0}">
					<div>
						<b>${modulo.moduloKey}</b>
						<p>C�digo</p>
					</div>
				</c:if>
				
				<div>
					<form:input path="modulo.descricao" cssClass="required" size="40"/>
					<p>Nome</p>
				</div>
			</div>
				
			<div align="center" class="buttons">
				<br />
				<button type="button" onclick="window.location.href='${raiz}modulos'">Cancelar</button>
				<button type="submit">Salvar</button><br/>
			</div>
		</form>		
	</body>
</html>
<%@ include file="/commons/taglibs.jsp"%>
<html>
	<head>
		<title>Cadastro de Usu�rios</title>
		<script>

			jQuery.validator.addMethod("username", function(value, element) { 
			  return this.optional(element) || /[a-z|A-Z|-|_]/.test(value); 
			}, "Por favor use apenas letras, n�meros, _ ou -.");
		
			$(function() {
				$('#formUsuario').validate();
				onChangePapeis();
			});
		
			function salvar() {
				$('#formUsuario').submit();
			}

			function onChangePapeis(){
				var ehCliente = temOPapelCliente();
				if (ehCliente) {
					$('#clienteKey').removeAttr('disabled');
				} else {
					$('#clienteKey').attr('disabled','disabled');
				}
			}		

			function temOPapelCliente() {
				var $papel = $('#papel');
				var papeis = new String($papel.val()).split(',');
				var tem = false;
				for (p in papeis) {
					tem = tem || parseFloat(papeis[p]) == 7;
				}
				return tem;
			}

			
		</script>
	</head>
	<body>
		<form action="${raiz}usuarios" method="post" id="formUsuario">
			<ul class="info">
				<h1>Cadastro de Usu�rios</h1>
			</ul>
			<div class="group">
				<c:choose>
					<c:when test="${usuario.username ne null}">
						<form:hidden path="usuario.username"/>
						<div>
							<b>${usuario.username}</b>
							<p>Username</p>
						</div>
					</c:when>
					<c:otherwise>
						<div>
							<form:input path="usuario.username" cssClass="required"/>
							<p>Username</p>
						</div>
					</c:otherwise>
				</c:choose>
				<div>
					<form:input path="usuario.nome" cssClass="required"/>
					<p>Nome</p>
				</div>
				<div>
					<form:input path="usuario.email" cssClass="email required" size="40"/>
					<p>E-mail</p>
				</div>
				<div>
					<form:input path="usuario.telefone" maxlength="20" />
					<p>Telefone</p>
				</div>
				<div>
					<form:input path="usuario.jabberUsername" size="40"/>
					<p title="ex: andrefaria@chat.bluesoft.com.br">Jabber username</p>
				</div>
				<c:if test="${usuario.username ne null}">
					<div>
						<p><img alt="Gravatar" align="top" title="Gravatar - Globally Recognized Avatars" src="http://www.gravatar.com/avatar/${usuario.emailMd5}" /></p>
						<p>Gravatar</p>
					</div>
				</c:if>
				<c:if test="${usuario.username eq null}">
					<div>
						<input type="password" name="password">
						<p>Senha</p>
					</div>
				</c:if>
				<div>
					<select size="5" multiple="multiple" name="papel" class="required" onchange="onChangePapeis()" id="papel">
						<c:forEach items="${papeis}" var="papel">
							<option value="${papel.papelKey}" ${usuario.mapaPapeis[papel.papelKey] ? 'selected="selected"' : ''}>${papel.descricao}</option>
						</c:forEach>
					</select>
					<p>Pap�is</p>
				</div>
				
				<div>
					<select name="clienteKey" disabled="disabled" id="clienteKey">
						<c:forEach items="${clientes}" var="cliente">
							<option value="${cliente.clienteKey}" ${usuario.cliente.clienteKey eq cliente.clienteKey ? 'selected="selected"' : ''}>${cliente.nome}</option>
						</c:forEach>
					</select>
					<p>Cliente</p>
				</div>
			</div>
				
			<div align="center" class="buttons">
				<br/>
				<button type="button" onclick="window.location.href='${raiz}usuarios'">Cancelar</button>
				<button type="button" onclick="salvar()">Salvar</button><br/>
			</div>
		</form>		
	</body>
</html>
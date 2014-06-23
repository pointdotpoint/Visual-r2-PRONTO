<%@ include file="/commons/taglibs.jsp"%>
<div class="htmlbox comentario" style="position: relative;">

	
	<div class="comentario-data">${zendeskTicketAtual.created_at}</div>

	<div class="person-comentario">		
		<div class="person">
			<pronto:icons name="zendesk.png" title="Zende	sk" onclick="openWindow('${zendeskUrl}/tickets/${zendeskTicketAtualKey}')" clazz="gravatar50"/>
			<div class="person_name">Zendesk</div>
		</div>
	</div>
	
	<div class="comentario-html">
		<h3>Ticket <a href="${zendeskUrl}/tickets/${zendeskTicketAtualKey}" target="_blank">#${zendeskTicketAtual.nice_id}</a> do Zendesk</h3>
		<b>Status:</b> ${zendeskTicketAtual.status}<br/>
		<b>Tipo:</b> ${zendeskTicketAtual.tipo}<br/>
		
		
	</div>

</div>

<c:if test="${!empty zendeskTicketAtual.comments}">
	<c:forEach items="${zendeskTicketAtual.comments}" var="comentario">
		<div class="htmlbox comentario" style="position: relative;">
			
			<div class="comentario-data">${comentario.created_at}</div>
			
			<div class="person-comentario">
				<div class="person">
					<img alt="Gravatar" align="left" src="http://www.gravatar.com/avatar/${comentario.author.emailMD5}?s=50"/>
					<div class="person_name">${comentario.author.name}</div>
				</div>
			</div>
			
			
			
			<div class="comentario-html">
				${comentario.html}
				
				<br/>
				<ul style="list-style-type: none;">
					<c:forEach items="${comentario.attachments}" var="anexo">
						<li>
							<pronto:icons name="anexo.png" title="${anexo.filename}"/>
							${anexo.filename}
							<pronto:icons name="download.gif" title="Baixar Anexo" onclick="openWindow('${anexo.url}')"/>
						</li>
					</c:forEach>
				</ul>
				
				
			</div>
			
		</div>
	</c:forEach>
	<br/>
</c:if>

<h3>Incluir coment�rio privado no Zendesk</h3>
<form action="${raiz}/zendesk/tickets/${zendeskTicketAtual.nice_id}/comentarios" method="post">
	<input type="hidden" name="ticketKey" value="${ticket.ticketKey}" />
	<div>
		<textarea id="comentarioZendesk${zendeskTicketAtual.nice_id}" name="comentarioZendesk" class="comentarioZendesk"></textarea>
	</div>
	<div align="center" class="buttons">
		<button type="submit">Incluir</button>
	</div>
</form>
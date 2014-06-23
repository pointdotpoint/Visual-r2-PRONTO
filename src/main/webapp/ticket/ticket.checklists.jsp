<%@ include file="/commons/taglibs.jsp"%>
<div>
	<h5>Checklist
		<pronto:icons name="adicionar.png" title="Incluir novo Checklist" onclick="incluirChecklist();" id="iconIncluirChecklist"/>
		<pronto:icons name="incluir_checklist_com_base_no_modelo.png" title="Incluir Checklist com base em um Modelo" onclick="exibirModelosDeChecklist();" id="iconIncluirChecklist"/>
	</h5>
</div>

<div id="checklistsArea">
	<c:forEach items="${ticket.checklists}" var="checklist">
		<div class="checklist" id="checklist-${checklist.checklistKey}">
			<span class="title">
				${checklist.nome}
				<pronto:icons name="excluir.png" title="Excluir checklist" onclick="excluirChecklist(${checklist.checklistKey});" clazz="iconExcluirChecklist"/>
			</span>
			<ul>
				<c:forEach items="${checklist.itens}" var="item">
					<li id="checklistItem-${item.checklistItemKey}">
						<input ${item.marcado ? 'checked="checked"' : ''} class="checklistItem" type="checkbox" checklistItemKey="${item.checklistItemKey}"/> 
						${item.descricao}
						<span class="excluirChecklistItem ui-icon ui-icon-close" title="Excluir item do checklist"></span>
					</li>
				</c:forEach>
			</ul>
			<input type="text" class="addChecklistItem" checklistKey="${checklist.checklistKey}" maxlength="120" size="40" title="Insira a descri��o do item e pressione ENTER para salv�-lo"/>
				 <font size="2"><p>Incluir Item - </font><font size="1"><i>Insira a descri��o do item e pressione ENTER para salv�-lo</i></p></font>
			<hr/>
		</div>
	</c:forEach>
</div>

<div id="dialogSelecionarModelo" style="display: none;">
	Escolha um Modelo:
	<select id="modelosDeChecklist">
	</select>
	<br/><br/>
	<button onclick="$('#dialogSelecionarModelo').dialog('close');">Cancelar</button>
	<button onclick="incluirChecklistComBaseEmModelo()">Incluir</button>
</div>
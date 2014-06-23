function recarregar(sprintKey) {
	goTo(pronto.raiz + 'backlogs/sprints/' + sprintKey);
}

function recarregarFiltros() {
	var url = location.href;
	
	if (url.indexOf('?') > 0) {
		url = url.substring(0, url.indexOf('?'));
	} 
	
	var categoriaKey = $('#categoriaKey').val();
	var tipoDeTicketKey = $('#tipoDeTicketKey').val();
	var kanbanStatusKey = $('#kanbanStatusKey').val();
	var ordem = $('#ordem').val();
	
	pronto.doGet(url + '?categoriaKey='+categoriaKey+'&tipoDeTicketKey='+tipoDeTicketKey+'&kanbanStatusKey='+kanbanStatusKey+'&ordem='+ordem);
}

function apagarLinha(ticketKey) {
	$('#' + ticketKey).add('tr[pai=' + ticketKey + ']').fadeOut('slow',
		function() {
			$(this).remove();
	});
}

function salvarCategoria(select) {
	var $select = $(select);
	var categoriaKey = $select.val();
	var ticketKey = $select.attr('ticketKey');
	var $td = $select.parents('td');

	var url = pronto.raiz + 'tickets/' + ticketKey + '/salvarCategoria';
	$.post(url, {
		'ticketKey' : ticketKey,
		'categoriaKey' : categoriaKey
	});

	if (categoriaKey > 0) {
		var $selectedOption = $select.find('option:selected');
		var clazz = $selectedOption.attr('categoriaClass');
		var $label = $('<span class="categoria ' + clazz + '"/>');
		$label.text($selectedOption.text());
		$td.append($label);
	}

	$td.attr('categoriaKey', categoriaKey);
	$select.hide();
	$select.removeAttr('ticketKey');
	$('#divCategorias').append($select);
}

function trocarCategoria(td) {
	var ticketKey = $(td).parents('tr').attr('id');
	var $select = $('#trocaCategoria');
	
	if (ticketKey != $select.attr('ticketKey')) {
		var $categoriaAtual = $(td).attr('categoriaKey');
		$select.val($categoriaAtual);
		
		$select.attr('ticketKey', ticketKey);
		$(td).append($select);
		$select.show();
		var $td = $select.parents('td');
		$td.find('.categoria').remove();
	}
}

function verDescricao(ticketKey) {
	var titulo = $('#' + ticketKey + ' .titulo').text();
	$.ajax( {
		url : pronto.raiz + 'tickets/' + ticketKey + '/descricao',
		cache : false,
		success : function(data) {
			$("#dialog").dialog('option', 'title',
					'#' + ticketKey + ' - ' + titulo);
			$("#dialogDescricao").html(data);
			$("#dialog").dialog('open');
		}
	});
}

function exibirOpcoes(tr) {
	$(tr).find('.opcao').show();
}

function esconderOpcoes(tr) {
	$(tr).find('.opcao').hide();
}

function criarDialog(){
	$("#dialog").dialog( {
		autoOpen : false,
		height : $(document).height() - 50,
		width : $(document).width() - 50,
		modal : true
	});
}

function criarEventoDeTrocarCategoria(){
	var $table = $('#ticketsTable'); 
	$table.find('tbody tr').mouseenter(function(){
		exibirOpcoes(this);
	}).mouseleave(function(){
		esconderOpcoes(this);
	});
}

function escolherSprintParaMover(ticketKey) {
	
	if ($('#selecionarSprint').length == 0){
		pronto.moverParaSprintAtual(ticketKey, true);
	} else {
		var $div = $("#dialogSelecionarSprint");
		$div.find('button').button();
		
		$("#ticketKey").val(ticketKey);
		
		var $dialog = $div.dialog();
		$dialog.dialog('open');
	}	
}

$(function() {
	criarDialog();
	criarEventoDeTrocarCategoria();
});

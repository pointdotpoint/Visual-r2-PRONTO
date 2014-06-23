package br.com.bluesoft.pronto.controller

import static org.springframework.web.bind.annotation.RequestMethod.*

import java.io.File
import java.text.MessageFormat
import java.util.ArrayList
import java.util.List
import java.util.Set
import java.util.TreeSet

import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse

import net.sf.json.JSONObject

import org.apache.commons.fileupload.FileItem
import org.apache.commons.fileupload.FileItemFactory
import org.apache.commons.fileupload.disk.DiskFileItemFactory
import org.apache.commons.fileupload.servlet.ServletFileUpload
import org.apache.commons.lang.math.NumberUtils
import org.hibernate.SessionFactory
import org.hibernate.Transaction
import org.hibernate.criterion.Restrictions
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.WebDataBinder
import org.springframework.web.bind.annotation.InitBinder
import org.springframework.web.bind.annotation.ModelAttribute
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.ResponseBody
import org.springframework.web.context.request.WebRequest

import br.com.bluesoft.pronto.ProntoException
import br.com.bluesoft.pronto.SegurancaException
import br.com.bluesoft.pronto.core.Backlog
import br.com.bluesoft.pronto.core.Papel
import br.com.bluesoft.pronto.core.TipoDeTicket
import br.com.bluesoft.pronto.dao.BacklogDao
import br.com.bluesoft.pronto.dao.CategoriaDao
import br.com.bluesoft.pronto.dao.CausaDeDefeitoDao
import br.com.bluesoft.pronto.dao.ClienteDao
import br.com.bluesoft.pronto.dao.ConfiguracaoDao
import br.com.bluesoft.pronto.dao.KanbanStatusDao
import br.com.bluesoft.pronto.dao.MilestoneDao
import br.com.bluesoft.pronto.dao.ModuloDao
import br.com.bluesoft.pronto.dao.MotivoReprovacaoDao
import br.com.bluesoft.pronto.dao.MovimentoKanbanDao
import br.com.bluesoft.pronto.dao.ProjetoDao
import br.com.bluesoft.pronto.dao.SprintDao
import br.com.bluesoft.pronto.dao.TicketDao
import br.com.bluesoft.pronto.dao.TipoDeTicketDao
import br.com.bluesoft.pronto.dao.UsuarioDao
import br.com.bluesoft.pronto.model.ChecklistItem
import br.com.bluesoft.pronto.model.Sprint
import br.com.bluesoft.pronto.model.Ticket
import br.com.bluesoft.pronto.model.TicketComentario
import br.com.bluesoft.pronto.model.TicketLog
import br.com.bluesoft.pronto.model.Usuario
import br.com.bluesoft.pronto.service.ChecklistService
import br.com.bluesoft.pronto.service.Config
import br.com.bluesoft.pronto.service.MessageFacade
import br.com.bluesoft.pronto.service.MovimentadorDeTicket
import br.com.bluesoft.pronto.service.Seguranca
import br.com.bluesoft.pronto.service.ZendeskService
import br.com.bluesoft.pronto.util.DateUtil
import br.com.bluesoft.pronto.util.FileUtil
import br.com.bluesoft.pronto.util.StringUtil
import br.com.bluesoft.pronto.web.binding.DefaultBindingInitializer

import com.google.common.collect.Lists

@Controller
@RequestMapping("/tickets")
class TicketController {

	public static final String VIEW_BRANCHES = "/ticket/ticket.branches.jsp"
	public static final String VIEW_EDITAR = "/ticket/ticket.editar.jsp"

	@Autowired CategoriaDao categoriaDao
	@Autowired ModuloDao moduloDao
	@Autowired ClienteDao clienteDao
	@Autowired SessionFactory sessionFactory
	@Autowired TicketDao ticketDao
	@Autowired SprintDao sprintDao
	@Autowired UsuarioDao usuarioDao
	@Autowired KanbanStatusDao kanbanStatusDao
	@Autowired TipoDeTicketDao tipoDeTicketDao
	@Autowired BacklogDao backlogDao
	@Autowired ConfiguracaoDao configuracaoDao
	@Autowired CausaDeDefeitoDao causaDeDefeitoDao
	@Autowired MotivoReprovacaoDao motivoReprovacaoDao
	@Autowired MovimentoKanbanDao movimentoKanbanDao
	@Autowired MovimentadorDeTicket movimentadorDeTicket
	@Autowired ZendeskService zendeskService
	@Autowired MessageFacade messenger
	@Autowired ProjetoDao projetoDao
	@Autowired ChecklistService checklistService
	@Autowired MilestoneDao milestoneDao

	@InitBinder
	public void initBinder(final WebDataBinder binder, final WebRequest webRequest) {
		def defaultBindingInitializer = new DefaultBindingInitializer()
		defaultBindingInitializer.initBinder binder, webRequest
	}

	@ModelAttribute("usuarios")
	List<Usuario> getUsuarios() {
		return usuarioDao.listar()
	}

	@ModelAttribute("tiposDeTicket")
	List<TipoDeTicket> getTiposDeTicket() {
		return tipoDeTicketDao.listar()
	}

	@RequestMapping("/branches")
	String branches( Model model) {
		List<Ticket> tickets = ticketDao.listarTicketsQueNaoEstaoNoBranchMaster()
		model.addAttribute("tickets", tickets)
		return VIEW_BRANCHES
	}

	@RequestMapping(value='/{ticketKey}/comentarios', method=[POST, PUT])
	String incluirComentario(@PathVariable int ticketKey, String comentario, String[] notificar){

		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.EQUIPE, Papel.SCRUM_MASTER

		if (comentario !=null&& comentario.trim().length() > 0) {
			Transaction tx = sessionFactory.getCurrentSession().beginTransaction()
			def ticket = ticketDao.obter(ticketKey)
			ticket.addComentario comentario, Seguranca.usuario
			ticketDao.salvar ticket
			tx.commit()
	
			if (notificar && notificar.size() > 0) {
				messenger.enviarComentario ticket, comentario, usuarioDao.listar(notificar)
			}
		}

		return "redirect:/tickets/${ticketKey}#comentarios"
	}
	
	@RequestMapping(value = "/{ticketKey}/comentarios/{ticketComentarioKey}", method=DELETE)
	@ResponseBody
	String excluirComentario(@PathVariable int ticketKey, @PathVariable int ticketComentarioKey)  {
		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.EQUIPE, Papel.SCRUM_MASTER
		Transaction tx = sessionFactory.getCurrentSession().beginTransaction()
		TicketComentario comentario = ticketDao.obterComentario(ticketComentarioKey)
		boolean result = false
		if (comentario.usuario.username == Seguranca.usuario.username) {
			ticketDao.excluirComentario(ticketComentarioKey)
			def ticket = comentario.ticket
			def data = DateUtil.toString(comentario.data)
			ticket.addLogDeExclusao("comentario", "${comentario.texto}. O comentário havia sido incluído em ${data}.")
			ticketDao.salvar(ticket)
			result = true
		}
		tx.commit()
		return String.valueOf(result)
	}

	@RequestMapping(method=[POST, PUT])
	String salvar( Model model, Ticket ticket,  String comentario,  String[] envolvido,  Integer paiKey,  Integer clienteKey, Integer motivoReprovacaoKey, Integer kanbanStatusAnterior) throws SegurancaException {

		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.EQUIPE, Papel.SCRUM_MASTER

		boolean isNovo = ticket.ticketKey <= 0

		try {

			if (!isNovo) {
				def dataDaUltimaAlteracao = DateUtil.getTimestampSemMilissegundos(ticketDao.obterDataDaUltimaAlteracaoDoTicket(ticket.ticketKey))
				if (dataDaUltimaAlteracao!= null && ticket.dataDaUltimaAlteracao < dataDaUltimaAlteracao) {
					def erro = 'Não foi possível alterar o ticket porque já ocorreram alterações depois que você começou a editá-lo!'
					return "redirect:/tickets/${ticket.ticketKey}?erro=${erro}";
				}
			}

			Transaction tx = sessionFactory.getCurrentSession().beginTransaction()

			if (ticket.getTitulo() == null || ticket.getTitulo().trim().length() <= 0) {
				throw new ProntoException("Não é possível salvar o ticket sem uma descrição!")
			}

			if (ticket.isDefeito()) {
				if (ticket.kanbanStatus.isFim() && (ticket.getCausaDeDefeito() == null || ticket.getCausaDeDefeito().getCausaDeDefeitoKey() == 0)) {
					return "redirect:/tickets/${ticket.ticketKey}?erro=Antes de mover para a última etapa é necessário informar a causa do defeito.";
				} else {
					ticket.setCausaDeDefeito(causaDeDefeitoDao.obter(ticket.getCausaDeDefeito().getCausaDeDefeitoKey()))
				}
			} else {
				ticket.setCausaDeDefeito(null)
			}

			if (ticket.projeto != null && ticket.projeto.projetoKey > 0) {
				ticket.setProjeto(projetoDao.obter(ticket.projeto.projetoKey))
				ticket.projeto.etapaDeInicioDoCiclo
				ticket.projeto.etapaDeTerminoDoCiclo
			} else {
				ticket.projeto = null
			}
			
			if (ticket.responsavel != null && ticket.responsavel.username != null) {
				ticket.responsavel = usuarioDao.obter(ticket.responsavel.username)
			} else {
				ticket.responsavel = null
			}

			if (ticket.getKanbanStatus() == null || ticket.getKanbanStatus().getKanbanStatusKey() == null) {
				if (ticket.projeto) {
					ticket.setKanbanStatus(ticket.projeto.etapaToDo)
				} else {
					ticket.setKanbanStatus(null)
				}
			} else {
				ticket.setKanbanStatus(kanbanStatusDao.obter(ticket.getKanbanStatus().getKanbanStatusKey()))
			}

			if (paiKey == null) {

				ticket.setBacklog(backlogDao.obter(ticket.getBacklog().getBacklogKey()))
				ticket.setTipoDeTicket(tipoDeTicketDao.obter(ticket.getTipoDeTicket().getTipoDeTicketKey()))

				if (ticket.getSprint() != null && ticket.getSprint().getSprintKey() <= 0) {
					ticket.setSprint(null)
				} else {
					ticket.setSprint((Sprint) sessionFactory.getCurrentSession().get(Sprint.class, ticket.getSprint().getSprintKey()))
				}
			} else {
				Ticket pai = ticketDao.obter(paiKey)
				copiarDadosDoPai(pai, ticket)
			}

			if (clienteKey != null) {
				ticket.setCliente(clienteDao.obter(clienteKey))
			} else {
				ticket.cliente = null
			}

			if (ticket.categoria != null && ticket.categoria.categoriaKey > 0) {
				ticket.setCategoria(categoriaDao.obter(ticket.categoria.categoriaKey))
			} else {
				ticket.categoria = null
			}

			if (ticket.modulo != null && ticket.modulo.moduloKey > 0) {
				ticket.setModulo(moduloDao.obter(ticket.modulo.moduloKey))
			} else {
				ticket.modulo = null
			}
			
			if (ticket.milestone != null && ticket.milestone.milestoneKey > 0) {
				ticket.setMilestone(milestoneDao.obter(ticket.milestone.milestoneKey))
			} else {
				ticket.milestone = null
			}

			if (ticket.getTicketKey() == 0) {
				ticket.setReporter(usuarioDao.obter(ticket.getReporter().getUsername()))
			}

			if (comentario != null && comentario.trim().length() > 0) {
				ticket.addComentario(comentario, Seguranca.getUsuario())
			}

			ticket.setReporter(usuarioDao.obter(ticket.getReporter().getUsername()))
			definirEnvolvidos(ticket, envolvido)
			ticketDao.salvar(ticket)
			
			ticketDao.salvar(ticket)
			tx.commit()

			if (!isNovo) {
				if (kanbanStatusAnterior != null && !kanbanStatusAnterior.equals(ticket.getKanbanStatus().getKanbanStatusKey())) {
					if (motivoReprovacaoKey != null && motivoReprovacaoKey > 0) {
						movimentadorDeTicket.movimentar ticket, ticket.kanbanStatus.kanbanStatusKey, motivoReprovacaoKey
					} else {
						movimentadorDeTicket.movimentar ticket, ticket.kanbanStatus.kanbanStatusKey
					}
				}
			}
			
			if (ticket.ticketKey > 0 && configuracaoDao.isZendeskAtivo()) {
				if (ticket.getTicketKey() != null && ticket.isDone()) {
					Set<Integer> zendeskTicketKey = ticketDao.obterTicketsIntegradosNoZendesk(Integer.valueOf(ticket.getTicketKey()))
					if (zendeskTicketKey && zendeskTicketKey.size() > 0) {
						zendeskTicketKey.each {
							zendeskService.notificarConclusao it, ticket.release
						}
					}
				}
			}

			model.addAttribute "zendeskTicketKey", ticketDao.obterTicketsIntegradosNoZendesk(ticket.ticketKey)
			return "redirect:/tickets/${ticket.ticketKey}"
		} catch ( Exception e) {
			e.printStackTrace()
			return "redirect:/tickets/${ticket.ticketKey}?erro=${e.message}"
		}
	}

	void definirEnvolvidos( Ticket ticket,  String[] envolvido) throws SegurancaException {
		Set<Usuario> envolvidosAntigos = new TreeSet<Usuario>(ticketDao.listarEnvolvidosDoTicket(ticket.getTicketKey()))
		if (envolvido != null && envolvido.length > 0) {
			ticket.setEnvolvidos(new TreeSet<Usuario>())
			for ( String username : envolvido) {
				ticket.addEnvolvido(usuarioDao.obter(username))
			}
		}
		ticket.addEnvolvido(usuarioDao.obter(ticket.reporter.username))

		String envolvidosAntigosStr = envolvidosAntigos == null || envolvidosAntigos.size() == 0 ? "nenhum" : envolvidosAntigos.toString()
		String envolvidosNovosStr = ticket.getEnvolvidos() == null || ticket.getEnvolvidos().size() == 0 ? "nenhum" : ticket.getEnvolvidos().toString()
		if (!envolvidosAntigosStr.equals(envolvidosNovosStr)) {
			ticket.addLogDeAlteracao("envolvidos", envolvidosAntigosStr, envolvidosNovosStr)
		}
	}

	@RequestMapping("/{ticketKey}/jogarNoLixo")
	String jogarNoLixo( Model model, @PathVariable int ticketKey,  HttpServletResponse response) throws SegurancaException {

		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.EQUIPE

		Ticket ticket = (Ticket) sessionFactory.getCurrentSession().get(Ticket.class, ticketKey)
		ticket.setBacklog((Backlog) sessionFactory.getCurrentSession().get(Backlog.class, Backlog.LIXEIRA))
		ticket.sprint = null
		ticketDao.salvar(ticket)
		return "redirect:/tickets/${ticketKey}"
	}

	@RequestMapping("/{ticketKey}/moverParaImpedimentos")
	String moverParaImpedimentos( Model model, @PathVariable  int ticketKey, String username,  HttpServletResponse response) throws SegurancaException {
		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.EQUIPE
		Ticket ticket = ticketDao.obter(ticketKey)
		def backlogAntigo = ticket.backlog.descricao
		ticket.setBacklog(backlogDao.obter(Backlog.IMPEDIMENTOS))
		ticket.setResponsavel(usuarioDao.obter(username));
		ticket.addLogDeAlteracao 'backlog', backlogAntigo, ticket.backlog.descricao
		ticketDao.salvar(ticket)
		messenger.notificarImpedimento ticket
		return "redirect:/tickets/${ticketKey}"
	}

	@RequestMapping("/{ticketKey}/moverParaBranchMaster")
	void moverParaBranchMaster( Model model,  @PathVariable int ticketKey,  HttpServletResponse response) throws SegurancaException {

		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.EQUIPE

		Ticket ticket = (Ticket) sessionFactory.getCurrentSession().get(Ticket.class, ticketKey)
		ticket.setBranch(Ticket.BRANCH_MASTER)
		ticketDao.salvar(ticket)
	}

	@RequestMapping("/{ticketKey}/moverParaProductBacklog")
	String moverParaProductBacklog( Model model,  @PathVariable int ticketKey,  HttpServletResponse response) throws SegurancaException {

		Ticket ticket = (Ticket) sessionFactory.getCurrentSession().get(Ticket.class, ticketKey)

		int backlogDeOrigem = ticket.getBacklog().getBacklogKey()
		def backlogAntigo = ticket.backlog.descricao
		if (backlogDeOrigem == Backlog.INBOX) {
			Seguranca.validarPermissao(Papel.PRODUCT_OWNER)
		}

		ticket.setBacklog((Backlog) sessionFactory.getCurrentSession().get(Backlog.class, Backlog.PRODUCT_BACKLOG))

		ticket.setSprint(null)
		ticket.addLogDeAlteracao 'backlog', backlogAntigo, ticket.backlog.descricao
		ticketDao.salvar(ticket)
		return "redirect:/tickets/${ticketKey}"
	}

	@RequestMapping("/{ticketKey}/moverParaSprintAtual")
	String moverParaOSprintAtual( Model model,  @PathVariable int ticketKey,  HttpServletResponse response) throws ProntoException {

		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.ADMINISTRADOR

		Sprint sprintAtual = sprintDao.getSprintAtual()

		return moverParaSprint(model, ticketKey, sprintAtual.getSprintKey(), response)
	}

	@RequestMapping("/{ticketKey}/moverParaSprint/{sprintKey}")
	String moverParaSprint( Model model,  @PathVariable int ticketKey, @PathVariable int sprintKey,  HttpServletResponse response) throws ProntoException {

		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.ADMINISTRADOR

		Ticket ticket = (Ticket) sessionFactory.getCurrentSession().get(Ticket.class, ticketKey)
		def backlogAntigo = ticket.backlog.descricao
		int backlogDeOrigem = ticket.getBacklog().getBacklogKey()

		switch(backlogDeOrigem) {
			case Backlog.INBOX:
			case Backlog.SPRINT_BACKLOG:
			case Backlog.PRODUCT_BACKLOG:
			case Backlog.FUTURO:
				break
			default:
				throw new ProntoException("Não é possível mover uma estória para um sprint se a mesma estiver impedida ou na lixera.")
				break
		}
		def sprint = sprintDao.obter(sprintKey)
		ticket.sprint = sprint
		ticket.projeto = sprint.projeto
		boolean mudouDeProjeto = ticket.kanbanStatus.projeto.projetoKey != sprint.projeto.projetoKey
		if (mudouDeProjeto) {
			ticket.kanbanStatus = sprint.projeto.getEtapaToDo()
		}
		ticket.backlog = backlogDao.obter(Backlog.SPRINT_BACKLOG)
		ticket.addLogDeAlteracao 'backlog', backlogAntigo, (ticket.backlog.descricao + ' (' + sprint.nome + ')')  
		ticketDao.salvar(ticket)

		return "redirect:/tickets/${ticket.ticketKey}"
	}

	@RequestMapping("/{ticketKey}/moverParaFuturo")
	String moverParaFuturo( Model model,  @PathVariable int ticketKey, HttpServletResponse response) throws ProntoException {

		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.ADMINISTRADOR

		Ticket ticket = (Ticket) sessionFactory.getCurrentSession().get(Ticket.class, ticketKey)
		def backlogAntigo = ticket.backlog.descricao
		ticket.setBacklog(backlogDao.obter(Backlog.FUTURO))

		ticket.setSprint(null)
		ticket.addLogDeAlteracao 'backlog', backlogAntigo, ticket.backlog.descricao
		ticketDao.salvar(ticket)
		return "redirect:/tickets/${ticketKey}"
	}

	@RequestMapping("/{ticketKey}/desacoplar")
	String desacoplar( Model model,  @PathVariable int ticketKey,  HttpServletResponse response) throws ProntoException {

		Seguranca.validarPermissao Papel.PRODUCT_OWNER
		Ticket ticket = (Ticket) sessionFactory.getCurrentSession().get(Ticket.class, ticketKey)

		if (ticket.isTarefa()) {
			ticket.addLogDeExclusao 'pai', ticket.pai.ticketKey
			ticket.setPai(null)
			ticket.setTipoDeTicket(tipoDeTicketDao.obter(TipoDeTicket.ESTORIA))
			ticketDao.salvar(ticket)
			return "redirect:/tickets/${ticket.ticketKey}"
		} else {
			def erro = 'Apenas tarefas podem ser desacopladas';
			return "redirect:/tickets/${ticket.ticketKey}?erro=${erro}"
		}
	}

	@RequestMapping("/{ticketKey}/moverParaInbox")
	String moverParaInbox( Model model, @PathVariable int ticketKey,  HttpServletResponse response) throws SegurancaException {

		Seguranca.validarPermissao Papel.PRODUCT_OWNER

		Ticket ticket = (Ticket) sessionFactory.getCurrentSession().get(Ticket.class, ticketKey)
		def backlogAntigo = ticket.backlog.descricao
		ticket.setBacklog((Backlog) sessionFactory.getCurrentSession().get(Backlog.class, Backlog.INBOX))
		ticket.setSprint(null)
		ticket.addLogDeAlteracao 'backlog', backlogAntigo, ticket.backlog.descricao
		ticketDao.salvar(ticket)
		return "redirect:/tickets/${ticket.ticketKey}"
	}

	@RequestMapping("/{ticketKey}/restaurar")
	String restaurar( Model model, @PathVariable  int ticketKey,  HttpServletResponse response) throws SegurancaException {

		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.EQUIPE

		Ticket ticket = (Ticket) sessionFactory.getCurrentSession().get(Ticket.class, ticketKey)

		boolean notificarImpedimento = ticket.backlog.isImpedimentos()
		
		Backlog backlog = null
		switch (ticket.getTipoDeTicket().getTipoDeTicketKey()) {
			case TipoDeTicket.ESTORIA:
			case TipoDeTicket.DEFEITO:
				if (ticket.getSprint() != null) {
					backlog = (Backlog) sessionFactory.getCurrentSession().get(Backlog.class, Backlog.SPRINT_BACKLOG)
					if (ticket.getSprint().isFechado()) {
						ticket.setSprint(sprintDao.getSprintAtual())
					}
				} else {
					backlog = (Backlog) sessionFactory.getCurrentSession().get(Backlog.class, Backlog.INBOX)
				}
				break
			case TipoDeTicket.TAREFA:
				backlog = ticket.getPai().getBacklog()
				break
		}

		def envolvidos = ticket.todosOsEnvolvidos
		ticket.setResponsavel(null)
		ticket.setBacklog(backlog)
		ticketDao.salvar(ticket)

		if (ticket.getFilhos() != null) {
			for ( Ticket filho : ticket.getFilhos()) {
				filho.setBacklog(backlog)
				ticketDao.salvar(ticket)
			}
		}

		if (notificarImpedimento) 
			messenger.notificarDesimpedimento ticket, envolvidos
		
		return "redirect:/tickets/${ticketKey}"
	}

	@RequestMapping("/{ticketKey}/upload")
	String upload( Model model,  HttpServletRequest request, @PathVariable int ticketKey) throws Exception {

		FileItemFactory factory = new DiskFileItemFactory()
		ServletFileUpload upload = new ServletFileUpload(factory)

		List<FileItem> items = upload.parseRequest(request)
		String ticketDir = Config.getImagesFolder() + ticketKey + "/"
		File dir = new File(ticketDir)
		dir.mkdirs()

		List<String> nomesDosArquivos = new ArrayList<String>()

		Ticket ticket = ticketDao.obter(ticketKey)

		for ( FileItem fileItem : items) {
			String nomeDoArquivo = StringUtil.retiraAcentuacao(fileItem.getName().toLowerCase().replace(' ', '_')).replaceAll("[^A-Za-z0-9._\\-]", "")

			if (FileUtil.ehUmNomeDeArquivoValido(nomeDoArquivo)) {
				fileItem.write(new File(ticketDir + nomeDoArquivo))

				nomesDosArquivos.add(nomeDoArquivo)
				ticket.addLogDeInclusao 'anexo', nomeDoArquivo
			} else {
				model.addAttribute("erro", "Não é possível anexar o arquivo '" + nomeDoArquivo + "' pois este não possui uma extensão.")
			}
		}

		this.insereImagensNaDescricao(ticketKey, nomesDosArquivos)

		ticketDao.salvar ticket

		return "redirect:/tickets/${ticketKey}"
	}

	void insereImagensNaDescricao( int ticketKey,  List<String> nomesDosArquivos) {
		Ticket ticket = ticketDao.obter(ticketKey)
		String novaDescricao = ticket.getDescricao()
		for ( String nomeDoArquivo : nomesDosArquivos) {
			if (FileUtil.ehImagem(FileUtil.getFileExtension(nomeDoArquivo))) {
				novaDescricao += "\r\n\r\n[[Image:" + ticketKey + "/" + nomeDoArquivo + "]]"
			}
		}
		ticket.setDescricao(novaDescricao)
		ticketDao.salvar(ticket)
	}


	@RequestMapping(value = '/anexos', method = GET)
	String download( HttpServletResponse response,  String file)  {
		def ticketKey = Integer.parseInt( file.replaceAll('(.*)?\\/.*', '$1'))
		def path = file.replaceAll('.*?\\/(.*)', '$1')
		return download(response, path, ticketKey)
	}

	@RequestMapping(value = '/{ticketKey}/anexos', method = GET)
	void download( HttpServletResponse response,  String file,  @PathVariable int ticketKey)  {
		FileUtil.setFileForDownload(ticketKey + "/" + file, response)
	}

	@RequestMapping(value = "/{ticketKey}/anexos", method=DELETE)
	String excluirAnexo(@PathVariable int ticketKey, String file)  {
		File arquivo = new File(Config.getImagesFolder() + ticketKey + "/" + file)
		if (arquivo.exists()) {
			arquivo.delete()
		}

		Ticket ticket = ticketDao.obter(ticketKey)
		ticket.addLogDeExclusao 'anexo', file
		ticketDao.salvar ticket

		return "redirect:/tickets/${ticketKey}"
	}
	
	


	@RequestMapping("/{ticketKey}/salvarValorDeNegocio")
	@ResponseBody String salvarValorDeNegocio( HttpServletResponse response, @PathVariable int ticketKey,  int valorDeNegocio) throws SegurancaException {
		try {
			Seguranca.validarPermissao Papel.PRODUCT_OWNER
			Ticket ticket = ticketDao.obter(ticketKey)
			ticket.setValorDeNegocio(valorDeNegocio)
			ticketDao.salvar(ticket)
			return "true"
		} catch (e) {
			return "false"
		}
	}

	@RequestMapping("/{ticketKey}/salvarBranch")
	@ResponseBody String salvarBranch( HttpServletResponse response, @PathVariable int ticketKey,  String branch) throws SegurancaException {
		try {
			Seguranca.validarPermissao Papel.EQUIPE
			Ticket ticket = ticketDao.obter(ticketKey)
			ticket.setBranch(branch)
			ticketDao.salvar(ticket)
			return "true"
		} catch (e) {
			return "false"
		}
	}

	@RequestMapping("/{ticketKey}/salvarEsforco")
	@ResponseBody String salvarEsforco( HttpServletResponse response, @PathVariable int ticketKey,  double esforco) throws SegurancaException {
		try {
			Seguranca.validarPermissao Papel.EQUIPE
			Ticket ticket = ticketDao.obter(ticketKey)
			ticket.setEsforco(esforco)
			ticketDao.salvar(ticket)
			return "true"
		} catch (e) {
			return "false"
		}
	}

	@RequestMapping("/{ticketKey}/salvarPar")
	@ResponseBody String salvarPar( HttpServletResponse response, @PathVariable int ticketKey,  boolean par) throws SegurancaException {
		try {
			Seguranca.validarPermissao Papel.EQUIPE
			Ticket ticket = ticketDao.obter(ticketKey)
			ticket.setPar(par)
			ticketDao.salvar(ticket)
			return "true"
		} catch (e) {
			return "false"
		}
	}

	@RequestMapping("/{ticketKey}/salvarCategoria")
	@ResponseBody String salvarCategoria( HttpServletResponse response, @PathVariable int ticketKey,  int categoriaKey) throws SegurancaException {
		try {
			Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.EQUIPE

			Ticket ticket = ticketDao.obter(ticketKey)
			ticket.setCategoria(categoriaKey > 0 ? categoriaDao.obter(categoriaKey) : null)
			ticketDao.salvar(ticket)
			return "true"
		} catch (e) {
			return "false"
		}
	}

	@RequestMapping("/{ticketKey}/transformarEmEstoria")
	String transformarEmEstoria( Model model,  @PathVariable int ticketKey) {

		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.EQUIPE

		Ticket ticket = ticketDao.obter(ticketKey)
		ticket.setTipoDeTicket((TipoDeTicket) sessionFactory.getCurrentSession().createCriteria(TipoDeTicket.class).add(Restrictions.eq("tipoDeTicketKey", TipoDeTicket.ESTORIA)).uniqueResult())
		ticketDao.salvar(ticket)

		return "redirect:/tickets/${ticketKey}"
	}

	@RequestMapping("/{ticketKey}/transformarEmDefeito")
	String transformarEmDefeito( Model model, @PathVariable int ticketKey)  {

		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.EQUIPE

		Ticket ticket = ticketDao.obter(ticketKey)

		if (ticket.getFilhos() != null && ticket.getFilhos().size() > 0) {
			model.addAttribute("erro", "Essa estória possui tarefas e por isso não pode ser transformada em um defeito.")
		} else {
			ticket.setTipoDeTicket((TipoDeTicket) sessionFactory.getCurrentSession().createCriteria(TipoDeTicket.class).add(Restrictions.eq("tipoDeTicketKey", TipoDeTicket.DEFEITO)).uniqueResult())
			ticketDao.salvar(ticket)
		}
		return "redirect:/tickets/${ticketKey}"
	}

	@RequestMapping("/{ticketKey}/descricao")
	String verDescricao( Model model, @PathVariable int ticketKey) throws Exception {
		Ticket ticket = ticketDao.obter(ticketKey)
		model.addAttribute("ticket", ticket)
		model.addAttribute("anexos", FileUtil.listarAnexos(String.valueOf(ticketKey)))
		return "/ticket/ticket.preview.jsp"
	}

	@RequestMapping(value = "/{ticketKey}", method = GET)
	String editar( Model model, @PathVariable  Integer ticketKey) throws SegurancaException {
		return editar(model, ticketKey, null)
	}

	@RequestMapping("/novo")
	String editar( Model model,  Integer ticketKey,  Integer tipoDeTicketKey) throws SegurancaException {

		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.EQUIPE

		if (ticketKey != null) {
			Ticket ticket = ticketDao.obterComDependecias(ticketKey)

			if (ticket == null) {
				model.addAttribute("mensagem", "O ticket #" + ticketKey + " não existe.")
				return "/branca.jsp"
			}

			if (ticket.ticketKey > 0 && configuracaoDao.isZendeskAtivo()) {
				def zendeskTicketKey = ticketDao.obterTicketsIntegradosNoZendesk(Integer.valueOf(ticket.getTicketKey()))
				if (zendeskTicketKey && zendeskTicketKey.size() > 0) {
					model.addAttribute "zendeskTicketKey", zendeskTicketKey
					model.addAttribute "zendeskUrl", configuracaoDao.getZendeskUrl()
					model.addAttribute "zendeskTicket", zendeskService.obterTickets(zendeskTicketKey)
				}
			}

			model.addAttribute("ticket", ticket)
			model.addAttribute("anexos", FileUtil.listarAnexos(String.valueOf(ticketKey)))
			model.addAttribute "motivosReprovacao", motivoReprovacaoDao.listar()
			model.addAttribute "movimentos", movimentoKanbanDao.listarMovimentosDoTicket(ticketKey)
			def ordens = new JSONObject();

			if (ticket.sprint != null) {
				def statusList = kanbanStatusDao.listarPorProjeto(ticket.projeto.projetoKey)
				model.addAttribute "kanbanStatus", statusList
				statusList.each {
					if (ticket.projeto.projetoKey == it.projeto.projetoKey) {
						ordens.put it.kanbanStatusKey as String, it.ordem as String
					}
				}
			} else {
				model.addAttribute "kanbanStatus", kanbanStatusDao.listar()
			}

			model.addAttribute "ordens", ordens
			model.addAttribute "zendeskTicketKey", ticketDao.obterTicketsIntegradosNoZendesk(ticket.ticketKey)
		} else {
			Ticket novoTicket = new Ticket()
			novoTicket.setReporter(Seguranca.getUsuario())
			novoTicket.setTipoDeTicket((TipoDeTicket) sessionFactory.getCurrentSession().get(TipoDeTicket.class, tipoDeTicketKey))
			novoTicket.setBacklog((Backlog) sessionFactory.getCurrentSession().get(Backlog.class, Backlog.INBOX))
			model.addAttribute("ticket", novoTicket)
			model.addAttribute("tipoDeTicketKey", tipoDeTicketKey)
			model.addAttribute "kanbanStatus", kanbanStatusDao.listar()
		}

		def equipe = usuarioDao.listarEquipe()

		model.addAttribute "categorias", categoriaDao.listar()
		model.addAttribute "modulos", moduloDao.listar()
		model.addAttribute "milestones", milestoneDao.listar()
		model.addAttribute "configuracoes", configuracaoDao.getMapa()
		model.addAttribute "clientes", clienteDao.listar()
		model.addAttribute "projetos", projetoDao.listarProjetosComSprintsAtivos()
		model.addAttribute "envolvidos", equipe
		model.addAttribute "causasDeDefeito", causaDeDefeitoDao.listar()

		VIEW_EDITAR
	}

	@RequestMapping("/{paiKey}/incluirTarefa")
	String incluirTarefa( Model model, @PathVariable int paiKey) throws Exception {

		Seguranca.validarPermissao Papel.PRODUCT_OWNER, Papel.EQUIPE

		Ticket pai = ticketDao.obter(paiKey)

		Ticket tarefa = new Ticket()
		copiarDadosDoPai(pai, tarefa)
		tarefa.setPrioridade(9999)

		model.addAttribute "ticket", tarefa
		model.addAttribute "tipoDeTicketKey", TipoDeTicket.TAREFA
		model.addAttribute "kanbanStatus", kanbanStatusDao.listar()
		model.addAttribute "envolvidos", usuarioDao.listarEquipe()

		return VIEW_EDITAR
	}

	void copiarDadosDoPai( Ticket pai,  Ticket filho) {
		filho.setPai(pai)
		if (filho.getReporter() == null || filho.getReporter().getUsername() == null) {
			filho.setReporter(Seguranca.getUsuario())
		}
		filho.setTipoDeTicket(tipoDeTicketDao.obter(TipoDeTicket.TAREFA))
		filho.setBacklog(pai.getBacklog())
		filho.setSprint(pai.getSprint())
		filho.setCliente(pai.getCliente())
		filho.setProjeto(pai.getProjeto())
		filho.setSolicitador(pai.getSolicitador())
	}

	@RequestMapping(value="/{pai}/ordenar", method=POST)
	@ResponseBody boolean alterarOrdem(@PathVariable int pai,  Integer[] ticketKey) {
		ticketDao.priorizarTarefas(ticketKey)
		return true
	}

	@RequestMapping("/{ticketKey}/log/{ticketHistoryKey}")
	String logDescricao( Model model, @PathVariable int ticketHistoryKey) {
		model.addAttribute "log", sessionFactory.currentSession.get(TicketLog.class, ticketHistoryKey)
		return "/ticket/ticket.logDescricao.jsp"
	}

	@RequestMapping("/{ticketKey}/selecionarOrigem")
	String selecionarOrigem(Model model, @PathVariable int ticketKey) {
		model.addAttribute("ticketKey", ticketKey)
		return "/ticket/ticket.selecionarOrigem.jsp"
	}

	@RequestMapping("/{ticketKey}/buscarTicketDeOrigem")
	String buscarTicketDeOrigem(Model model, @PathVariable int ticketKey, String query) {

		if (query != null && query != "") {
			if (NumberUtils.toInt(query) > 0) {
				Ticket ticket = ticketDao.obterTicketPronto(NumberUtils.toInt(query))
				if (ticket != null) {
					model.addAttribute("tickets", Lists.newArrayList(ticket))
				}
			} else {
				//				TicketOrdem ticketOrdem = TicketOrdem.TITULO
				//				Classificacao ticketClassificacao = Classificacao.ASCENDENTE
				//				def tickets = ticketDao.buscar(query, KanbanStatus.DONE, null, ticketOrdem, ticketClassificacao, null)
				//				model.addAttribute("tickets", tickets)
			}
		} else {
			model.addAttribute("mensagem", "Digite o número do ticket ou sua descrição.")
		}
		model.addAttribute("ticketKey", ticketKey)
		return "/ticket/ticket.selecionarOrigem.jsp"
	}

	@RequestMapping("/{ticketKey}/salvarOrigem")
	@ResponseBody String salvarOrigem(Model model, @PathVariable int ticketKey, int ticketOrigemKey) {
		try {
			Ticket ticket = ticketDao.obter(ticketKey)
			ticket.setTicketOrigem ticketDao.obter(ticketOrigemKey)
			ticketDao.salvar ticket
			return "true"
		} catch (e) {
			return "false"
		}
	}

	@RequestMapping("/{ticketKey}/vincularTicketAoZendesk")
	@ResponseBody String vincularTicketAoZendesk(Model model, @PathVariable int ticketKey, int zendeskTicketKey) {
		JSONObject json = new JSONObject()
		try {
			ticketDao.inserirTicketKeyIntegradoComZendesk ticketKey, zendeskTicketKey
			zendeskService.incluirComentarioPrivado zendeskTicketKey, 'Ticket integrado com o Pronto.\r\n\r\nPara visualizá-lo acesse: ' + configuracaoDao.getProntoUrl() + 'tickets/' + ticketKey
			json.put "isSuccess", "true"
			return json
		} catch (e) {
			json.put "isSuccess", "false"
			json.put "mensagem", e.getMessage()

			return json
		}
	}

	@RequestMapping("/{ticketKey}/excluirVinculoComZendesk/{zendeskTicketKey}")
	@ResponseBody String excluirVinculoComZendesk(Model model, @PathVariable int ticketKey, @PathVariable int zendeskTicketKey) {
		try {
			ticketDao.excluirVinculoComZendesk ticketKey, zendeskTicketKey
			return "true"
		} catch (e) {
			return "false"
		}
	}

	@RequestMapping("/{ticketKey}/excluirTicketDeOrigem")
	String excluirTicketDeOrigem(Model model, @PathVariable int ticketKey) {

		Ticket ticket = ticketDao.obter(ticketKey)
		ticket.setTicketOrigem(null)
		ticketDao.salvar ticket

		return "redirect:/tickets/${ticketKey}"
	}

	@ResponseBody
	@RequestMapping(value="/{ticketKey}/checklists", method=POST)
	def criarChecklist(@PathVariable int ticketKey, String nome) {
		checklistService.criarChecklist(ticketKey, nome).checklistKey
	}
	
	@ResponseBody
	@RequestMapping(value="/{ticketKey}/checklists/modelo/{modelo}", method=POST)
	def incluirChecklistComBaseEmModelo(@PathVariable int ticketKey, @PathVariable int modelo) {
		def checklist = checklistService.criarChecklistComBaseEmModelo(ticketKey, modelo)
		return [
			checklistKey: checklist.checklistKey,
			nome: checklist.nome,
			itens: checklist.itens.collect { ChecklistItem item ->
				return [checklistItemKey: item.checklistItemKey, descricao: item.descricao]
			}
		]
	}
	
	@ResponseBody
	@RequestMapping(value="/{ticketKey}/checklists/{checklistKey}", method=POST)
	def incluirItemNoChecklist(@PathVariable int ticketKey, @PathVariable int checklistKey, String descricao) {
		checklistService.incluirItem(checklistKey, descricao).checklistItemKey
	}
	
	@ResponseBody
	@RequestMapping(value="/{ticketKey}/checklists/{checklistKey}/{checklistItemKey}", method=DELETE)
	def removerChecklistItem(@PathVariable int ticketKey, @PathVariable int checklistKey, @PathVariable int checklistItemKey) {
		return checklistService.removerItem(checklistItemKey)
	}
	
	@ResponseBody
	@RequestMapping(value="/{ticketKey}/checklists/{checklistKey}", method=DELETE)
	def excluirChecklist(@PathVariable int ticketKey, @PathVariable int checklistKey) {
		checklistService.excluir checklistKey
		return true
	}
	
	@ResponseBody
	@RequestMapping(value="/{ticketKey}/checklists/{checklistKey}/{checklistItemKey}", method=POST)
	def marcarChecklist(@PathVariable int ticketKey, @PathVariable int checklistKey, @PathVariable int checklistItemKey) {
		return checklistService.toogleItem(checklistItemKey)
	}
	
}

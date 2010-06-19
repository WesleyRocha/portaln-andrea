class Notificador < ActionMailer::Base

  def email_contato mensagem, configuracao
    @mensagem = mensagem
    
    recipients configuracao.email
    from @mensagem[:email]
    subject "[#{I18n.t('portaln.nome_aplicacao')}] #{@mensagem[:assunto]}"
  end

end
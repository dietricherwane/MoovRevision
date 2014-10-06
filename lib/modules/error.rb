module Error
  
  def self.valid_gaming_session(gaming_session, screen_id)
    return xml_skeleton("MOOV REVISION-\n\nVous avez une session de jeu active jusqu'au: #{gaming_session.expires_at.strftime("%d-%m-%y") rescue nil}. Pour annuler cette inscription, envoyez: STOP.", screen_id)
  end
  
  def self.create_account(screen_id)
    return xml_skeleton("MOOV REVISION-4\n\nVeuillez réessayer plus tard.", screen_id)
  end
  
  def self.create_gaming_session(screen_id)
    return xml_skeleton("MOOV REVISION-5\n\nVeuillez réessayer plus tard.", screen_id)
  end
  
  def self.billing(screen_id)
    return xml_skeleton("MOOV REVISION-3\n\nVotre compte n'a pas pu être débité.", screen_id)
  end
  
  def self.xml_skeleton(text, screen_id)
    text = URI.escape(text)
    
    return "<?xml version='1.0' encoding='utf-8'?>
    <response>
      <screen_type>form</screen_type>
      <text>#{text}</text>
      <session_op>end</session_op>
      <screen_id>#{screen_id}</screen_id>
    </response>
    "
  end
  
  def self.session_over
    return "MOOV REVISION\nVous avez répondu à 20 questions. Veuillez attendre demain pour pouvoir rejouer."
  end
  
  def self.create_an_account_first
    return "send_question(question.wording) Veuillez créer un compte au préalable en envoyant XXX au XXXXX."
  end

end

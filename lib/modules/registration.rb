module Registration
  
  def self.validate_registration(screen_id)
    return xml_skeleton("form", "Bienvenue au jeu MOOV REVISION. Votre inscription a bien été prise en compte. Répondez aux questions, cumulez le maximum de points et gagnez de nombreux lots.", [], 0, "end", screen_id)
  end
  
  def self.xml_skeleton(screen_type, text, menu_options, back_link, session_op, screen_id)
    text = URI.escape(text)
    unless menu_options.blank?
      my_menu = get_menu(menu_options)
    end
    
    return "<?xml version='1.0' encoding='utf-8'?>
    <response>
      <screen_type>#{screen_type}</screen_type>
      <text>#{text}</text>
      #{my_menu}
      <back_link>#{back_link}</back_link>
      <home_link>0</home_link>
      <session_op>#{session_op}</session_op>
      <screen_id>#{screen_id}</screen_id>
    </response>
    "
  end
  
  def self.get_menu(menu_options)
    my_menu = "<options>"
    menu_options.each do |menu_option|
      my_menu << "<option choice = '#{menu_option[0]}'>#{menu_option[1]}</option>"
    end
    my_menu << "</options>"
  end

end

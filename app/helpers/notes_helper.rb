module NotesHelper
  def note_action_eql? action, actions
    for a in actions
      if action.eql? a
        return true
      end
    end
    nil
  end

  def current_title
    title = ""
    # shows number of notes in parantheses if any unseen notes are present
    title << "(" + currently_unseen_notes.size.to_s + ") " if currently_unseen_notes.present?
    # always gets the correct title based on the domain name
    title << get_site_title
    # applies kristin if kristins profile
    title << " — Kristin <3" if @kristin
    return title
  end

  def namify_note_message note
    if note.message and note.message.include? "Someone"
      if User.find_by_id note.sender_id
        return note.message.gsub("Someone", User.find(note.sender_id).name)
      elsif note.sender_token.present?
        return note.message.gsub("Someone", "Someone anonymously")
      end
    else
      return note.message
    end
  end

  def currently_unseen_notes
    current_notes.unseen
  end

  def current_notes
    if current_user
      current_user.notes
    else
      Note.where(anon_token: anon_token)
    end
  end
end

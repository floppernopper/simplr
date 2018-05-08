module ProposalsHelper
  def action_label proposal
    actions = []; for action in [proposal.revised_action, proposal.action]
      actions << "#{action}".gsub("_", " ").capitalize if action
    end
    label = ""; for action in actions
      label << action
      label << " · " if actions.size.even? and not action.eql? 'Revision'
    end
    label
  end

  def global_titles
    titles = [["Titles to grant", nil]]
  end

  def group_titles
    titles = [["Titles to grant", nil],
      ["Admin", "admin"],
      ["Mod", "mod"]]
  end

  def action_types group=nil
		actions = [["Action to be proposed", nil]]
    actions_hash = group ? Proposal.group_action_types : Proposal.action_types
		actions_hash.each do |key, val|
      actions << [val, key.to_s]
    end
    return actions
  end
end

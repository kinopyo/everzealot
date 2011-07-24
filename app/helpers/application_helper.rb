module ApplicationHelper
  def mark_required(object, attribute)
    mark = "<span class='require_mark'>*</span>"
    mark if object.class.validators_on(attribute).map(&:class).include? ActiveModel::Validations::PresenceValidator
  end

end

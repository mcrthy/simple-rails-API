module ExceptionHandler
  extend ActiveSupport::Concern

  class InvalidParam < StandardError; end

  included do
    rescue_from ActionController::ParameterMissing, with: :four_hundred
    rescue_from ExceptionHandler::InvalidParam, with: :four_hundred
  end

  private

  def four_hundred(e)
    json_response({ message: e.message}, 400)
  end
end
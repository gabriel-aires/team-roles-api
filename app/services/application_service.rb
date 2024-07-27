class ApplicationService
  
  # Service entrypoint
  def self.call(params)
    new(params).call
  end

  # Set @params and initialize the @errors array
  def initialize(params)
    @params = params
    @errors = []
  end

  # Override this method to implement service
  def call
    raise NotImplementedError
  end

  private

  def success_response(body, code = :ok)
    { body:, code: }
  end

  def error_response(errors, code = :bad_request)
    { body: { errors: }, code: }
  end  
end
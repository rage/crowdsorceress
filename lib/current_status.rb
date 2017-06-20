class CurrentStatus
  @@current_status = {
      'status' => 'in progress',
      'message' => 'Connection established',
      'progress' => 0.05,
      'result' => { 'OK' => false, 'ERROR' => [] }
  }

  def set_current_status(status, message, progress, result)
    @@current_status = {
        'status' => status,
        'message' => message,
        'progress' => progress,
        'result' => result
    }
  end

  def current_status
    @@current_status
  end
end
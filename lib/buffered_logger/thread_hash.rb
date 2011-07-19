class BufferedLogger::ThreadHash < Hash

  def []=(k,v)
    sweep if !include?(k) && k.is_a?(Thread)
    super
  end

  def sweep
    self.delete_if { |k,v| k.is_a?(Thread) && !k.alive? }
  end

end

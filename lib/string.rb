class String
  def truncate max
    length > max ? "#{self[0...max]}..." : self
  end

  def blank?
    self.strip == ""
  end
end

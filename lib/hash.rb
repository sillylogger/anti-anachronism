class Hash
  def deep_slice *keys
    custom_deep_slice a: self, keys: keys
  end

  private

  def custom_deep_slice(a:, keys:)
    result = a.slice(*keys)
    a.keys.each do |k|
      if a[k].class == Hash
        result.merge! custom_deep_slice(a: a[k], keys: keys)
      end
    end
    result
  end
end

class WhoisRecord < ActiveRecord::Base
  def full_body
    @disclosed = (json['disclosed'] || []).dup
    return body.to_s if @disclosed.empty?


    @full_body = ''
    @disclosed = @disclosed.each_with_object(Hash.new([])){|e,h| h[e.first] += [e.last]}
    disc_keys = "(" + @disclosed.keys.map{|e| " ?#{e}: " }.join("|") + ")"

    # add disclosed elements
    body.to_s.each_line do |line|
      if line.match(": +Not Disclosed")
        key_column = line.split(":").first
        new_line   = line.split(/Not Disclosed.+/).insert(1, @disclosed[key_column].shift || "not set")

        @full_body << new_line.join
      else
        @full_body << line
      end
    end
    @full_body
  end

  def public_body
    # remove whois only content
    body.to_s.gsub(/  email:     Not Disclosed.*$/, '  email:      Not Disclosed')  
  end

  def public_json
    @public_json = {}
    @disclosed_keys = (json.delete('disclosed') || []).dup.map(&:first).uniq

    # handle disclosed values
    json.each do |k,v|
      if v.is_a? Array
        v.each do |arrays_hash|
          @disclosed_keys.each do |disclosed_key|
            arrays_hash[disclosed_key] = 'Not Disclosed' if arrays_hash[disclosed_key].present?
          end
        end
        @public_json[k] = v
      else
        @disclosed_keys.each do |disclosed_key|
          @public_json[disclosed_key] = 'Not Disclosed' if @public_json[disclosed_key].present?
        end
        @public_json[k] = v
      end
    end
    @public_json
  end

  def full_json
    json.delete('disclosed')
    json
  end

end

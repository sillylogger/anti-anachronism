module Stats

  def print_stats label, key_to_count, total, limit = 50
    rows = key_to_count.sort_by{|k,v| v }.reverse[0, limit]

    rows_with_percent = rows.map{|key, count|
      [ key,
        count,
        "%0.2f" % (count / total.to_f * 100) ]
    }

    table = Terminal::Table.new(
      headings: [{
        value: label,
        alignment: :center
      },{
        value: "Total: #{total}",
        alignment: :center
      },{
        value: "%",
        alignment: :center
      }],
      rows: rows_with_percent
    )
    table.align_column 0, :left

    $log.info "\n" + table.to_s
  end

end

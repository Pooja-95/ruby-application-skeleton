require 'json'
require 'byebug'

class App
  def initialize(path_to_pages)
    @path_to_pages = path_to_pages
    @files_data = []
  end

  def run_script
    load_files_data
    table_headers = extract_page_table_headers
    tables = extract_tables_data
    display_results(tables, table_headers)
  end

  private

  def load_files_data
    files = Dir["#{@path_to_pages}/**/*.json"].sort
    files.each do |file|
      @files_data << JSON.parse(File.read(file))
    end
  end

  def extract_page_table_headers
    page_table_counts = Hash.new(0)
    table_details = []

    @files_data.each do |file|
      current_page = nil

      file.each do |block|
        case block['BlockType']
        when 'PAGE'
          current_page = block['Page']
        when 'TABLE'
          if current_page
            page_table_counts[current_page] += 1
            table_details << { page: current_page, table_position: page_table_counts[current_page] }
          end
        end
      end
    end

    { page_table_counts: page_table_counts, table_details: table_details }
  end

  def extract_tables_data
    tables = []

    @files_data.each do |data|
      data.each do |block|
        tables << extract_table_data(block) if block['BlockType'] == 'TABLE'
      end
    end

    tables
  end

  def extract_table_data(block)
    cells_data = block['Children'].map { |c| find_block_by_id(c) }
    cells = cells_data.select { |b| b["BlockType"] == "CELL" }

    cells.group_by { |cell| cell["CellLocation"]["R"] }.sort.map do |_, row_cells|
      row_cells.sort_by { |cell| cell["CellLocation"]["C"] }.map { |cell| extract_text_from_cell(cell) }
    end
  end

  def extract_text_from_cell(cell_block)
    word_blocks = cell_block["Children"].map { |id| find_block_by_id(id) }
    words = word_blocks.select { |block| block["BlockType"] == "WORD" }
    words.map { |word| word["Text"] }.join(" ")
  end


  def find_block_by_id(c_id)
    @files_data.each do |data|
      data.each do |block|
        return block if block['Id'] == c_id
      end
    end
    nil
  end

  def display_results(tables, table_headers)
    table_headers[:table_details].each_with_index do |table_detail, index|
      page = table_detail[:page]
      table_position = table_detail[:table_position]
      page_table_count = table_headers[:page_table_counts][page]

      puts "Page: #{page} —— Table: #{table_position} of #{page_table_count}"
      puts

      table = tables[index]
      table.each { |row| puts row.join(", ") }
      puts
    end
  end
end

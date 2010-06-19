module PortalN
  module Searchable
    def self.included(klass)
      klass.extend ClassMethods
    end
  
    module ClassMethods
      # ========================================================================================
      # Metodos publicos
      # ========================================================================================
      public
      
      # seach_hash => { 
      #   :select => {}
      #   :params => {},
      #   :joins => {},
      #   :order => {}
      # }
      #      
      # Para determinar a query de um determinado atributo utilize um parâmetro do tipo Hash, no seguinte
      # formato:
      # ... params => {
      #     ...
      #     :nome_do_parametro => {
      #         :query => "query especifica a ser utilizada",
      #         :values => ["valor1 a ser utilizado", "valor2", ...]
      #     }
      # }
      #
      # nsearch recebe dois parametros, o search_hash e o page_size que recebe o valor padrao PortalN::PAGE_SIZE
      #
      def nsearch(search_hash, page_size = PortalN::PAGE_SIZE)
        params = search_hash[:params]
        page = params[:page] ? params[:page] : 1
        params.delete(:page)

        if search_hash[:select].nil? or search_hash[:select].empty?
          search_hash[:select] = nil
        end
                                                                                                               
        params.keys.each do |key|
          eliminar_espacos_em_branco(params, key)
          eliminar_nil_vazio(params, key) 
          converter_key_em_symbol(params, key)
        end
                             
        # Recupera todos
        if params.nil? or params.empty?
          return self.paginate( 
            :select => search_hash[:select],
            :per_page => page_size,
            :page => page,
            :joins => search_hash[:joins],
            :order => search_hash[:order]
          )
        end             

        self.paginate(
          :select => search_hash[:select],
          :per_page => page_size,
          :page => page,         
          :conditions => generate_search_conditions(params),
          :joins => search_hash[:joins],
          :order => search_hash[:order]
        )
      end
    
      def generate_search_conditions(params)
        preencher_valores(params, montar_query(params))
      end
      
      # ========================================================================================
      # Metodos privados
      # ========================================================================================
      private              
    
      # Elimina espaços em branco no começo e final da string
      # Ex: "   teste   " => "teste"
      #
      def eliminar_espacos_em_branco(params, key)
        if params[key].class == String
          params[key].strip!
        end
      end
      # Elimina os valores nil e vazio ('')
      #         
      def eliminar_nil_vazio(params, key)
        if params[key].nil? or (params[key].class == String and params[key].empty?)
          params.delete(key)
        end
      end
              
      # Garante que todas as chaves sao simbolos
      #
      def converter_key_em_symbol(params, key)
        if params[key] and key.class != Symbol    
          params[key.intern] = params[key]
          params.delete key
          return true
        
        elsif params[key] and key.class == Symbol
          return true
        end
      
        false
      end
               
      def int?(params, key)
        begin              
          Integer(params[key])
          return true
        rescue ArgumentError
        end          
        false
      end

      def montar_query(params)
        query = ""
        params.keys.sort.each do |key|
          if params[key].class == String
            montar_parametro_string(query, params, key)
               
          elsif params[key].class == Hash
            query << "(#{params[key][:query]}) and "
          
          else
            query << "#{key.to_s} = ? and "
          end
        end                           
        query.gsub!(/\sand\s$/, '')
        query
      end          

      def montar_parametro_string(query, params, key)
        # Quebra pelos espacos
        parts = params[key].split(/\s+/)

        # Caso tenha mais de um espaco eh palavra composta
        if parts.length > 1                        
          trata_nome_composto(query, key, parts)          

        else  
          if int?(params, key)                       
            query << "#{key.to_s} = ? and "
          else
            query << "upper(#{key.to_s}) like ? and "
          end
        end
      end

      def trata_nome_composto(string, key, parts)
        string << "("
        parts.each do |part|
          string << "upper(#{key.to_s}) like ? or "
        end                                     
        string.gsub!(/\sor\s$/, '')
        string << ") "
      end    

      def preencher_valores(params, query)
        valores = []
        valores << query

        params.keys.sort.each do |key|
        
          if params[key].class == String
            preenche_valores_string(valores, params, key)
          
          elsif params[key].class == Hash
                                        
            # Usa uma notacao mais natural quando so tem 1 valor (:value)
            if params[key].has_key? :value
              value = params[key][:value]
              if value.class == String
                valores << value.upcase
              else                     
                valores << value
              end
            
            # para varios valores (:values)  
            else
              params[key][:values].each do |value|
                if value.class == String
                  valores << value.upcase
                else                     
                  valores << value
                end
              end
            end
          
          else
            valores << params[key]
          end
        end         
        valores
      end 

      def preenche_valores_string(valores, params, key)
        # Quebra pelos espacos em branco
        parts = params[key].split(/\s+/)

        # Verifica se eh palavra composta
        if parts.length > 1
          preenche_nome_composto(valores, parts)
        else                  
          if int?(params, key)                  
            valores << "#{params[key]}"
          else
            valores << "%#{params[key].upcase}%"
          end
        end
      end

      def preenche_nome_composto(array, parts)
        parts.each do |part|                
          array << "%#{part.upcase}%"
        end
      end
    
    end
  end  
end

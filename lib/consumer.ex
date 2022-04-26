defmodule Botdiscord.Consumer do

  use Nostrum.Consumer
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    cond do
      String.starts_with?(msg.content, "!tempo ") -> handleWeather(msg)
      msg.content == "!tempo" -> Api.create_message(msg.channel_id, "Use **!tempo** <nome-da-cidade>")

      String.starts_with?(msg.content, "!news ") -> handleNews(msg)
      msg.content == "!news" -> Api.create_message(msg.channel_id, "Use !news <categoria>, onde categoria deve ser business, sports, politics, technology, startup")

      String.starts_with?(msg.content, "!covid ") -> handleCovid(msg)
      msg.content == "!covid" -> Api.create_message(msg.channel_id, "Use !covid <país>, onde país deve ser o nome do país em inglês (ex: Brazil, France, Portugal, etc...)")

      String.starts_with?(msg.content, "!coffee") -> handleCoffee(msg)
      
      String.starts_with?(msg.content, "!pokemon ") -> handlePokemon(msg)
      msg.content == "!pokemon" -> Api.create_message(msg.channel_id, "Use !pokemon <nome>, onde nome deve ser o nome de um pokemon (ex: Ditto, Charmander, Bulbasaur, etc...)")

      String.starts_with?(msg.content, "!dog") -> handleDog(msg)
      
      String.starts_with?(msg.content, "!stoicism") -> handleStoicism(msg)

      String.starts_with?(msg.content, "!rickmorty ") -> handleRickMorty(msg)
      msg.content == "!rickmorty" -> Api.create_message(msg.channel_id, "Use !rickmorty <nome>, onde nome deve ser o nome de um personagem da série Rick and Morty (ex: Rick, Morty, etc...)")

      String.starts_with?(msg.content, "!detect ") -> handleDetectLanguage(msg)
      msg.content == "!detect" -> Api.create_message(msg.channel_id, "Use !detect <frase>, onde a frase deve ser em algum idioma para detectarmos.")

      String.starts_with?(msg.content, "!password") -> handlePassword(msg)

      String.starts_with?(msg.content, "!validaCEP ") -> handleValidaCEP(msg)
      msg.content == "!validaCEP" -> Api.create_message(msg.channel_id, "Use !validaCEP <cep>, onde cep deve ser algum cep válido (ex: 60125025, etc...).")

      String.starts_with?(msg.content, "!lol ") -> handleLol(msg)
      msg.content == "!lol" -> Api.create_message(msg.channel_id, "Use !lol <campeao>, onde campeao deve ser o nome de um personagem do jogo League Of Legends (ex: Aatrox, Yorick, etc...)")

      String.starts_with?(msg.content, "!expressao ") -> handleExpressao(msg)
      msg.content == "!expressao" -> Api.create_message(msg.channel_id, "Use !expressao <tipo>, onde tipo deve ser random (expressão aleatória), add (soma), sub (subtração), mul (multiplicação) e div (divisão)")

      String.starts_with?(msg.content, "!help") -> Api.create_message(msg.channel_id, "Os comandos são:\n
       !tempo <nome-da-cidade> -> Ver como está a temperatura naquela cidade em °C.\n
       !news <categoria> -> Ver as notícias acerca da categoria (business, sports, politics, technology, startup) digitada.\n
       !covid <país> -> Ver a quantidade de casos e mortes de covid naquele país (deve ser o nome em inglês).\n
       !coffee -> Imagem de café aleatório para você ficar com água na boca hehe!\n
       !pokemon <nome> -> Ver uma imagem do pokemon referente ao nome (ex: Ditto, Charmander) digitado.\n
       !dog -> Imagem de um cachorro aleatório para você apreciar a fofura.\n
       !stoicism -> Frase aleatória sobre a doutrina estoicismo (preza a fidelidade ao conhecimento e o foco em tudo aquilo que pode ser controlado somente pela própria pessoa.).\n
       !rickmorty <nome> -> Ver informações sobre um personagem da série Rick and Morty onde nome deve ser um personagem da série (ex: Rick, Morty).\n
       !detect <frase> -> Identificar qual é o idioma da frase digitada (OBS: não é aceito todos os idiomas, ex: japonês e caracteres especiais (tem que ser caracteres contidos na tabela ascii)).\n
       !password -> Gerar uma senha aleatória para você usar em cadastros.\n
       !validaCEP <cep> -> Ver informações sobre o cep (ex: 60125025) digitado.\n
       !lol <campeao> -> Ver informações sobre aquele campeão (ex: Yorick, Aatrox) do jogo League of Legends.\n
       !expressao <tipo> -> Gerar expressão aleatória de acordo com o tipo (add, sub, mul, div).")
      String.starts_with?(msg.content, "!") -> Api.create_message(msg.channel_id, "Comando inválido, tente novamente! Digite !help para ver as opções")

      true -> :ignore
    end
  end

  # Funções auxiliares

  defp formatarTexto(texto) do
    aux = String.replace(texto, " ", "%20")

    aux
  end

  defp maiusculoTexto(texto) do
    aux = String.split(texto, " ");

    vetorTexto = for n <- aux, do: String.capitalize(n)
  end

  def handle_event(_event) do
    :noop
  end

  defp handleExpressao(msg) do
    aux = String.split(msg.content, " ")
    tipo = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://x-math.herokuapp.com/api/#{tipo}")

    case resp.status_code do
      200 -> 
        {:ok, map} = Poison.decode(resp.body)
        Api.create_message(msg.channel_id, "Expressão: #{map["expression"]} | Resposta: #{map["answer"]}")
      404 -> 
        Api.create_message(msg.channel_id, "Tipo inválido, tente novamente!")
      503 -> 
        Api.create_message(msg.channel_id, "Serviço indisponível no momento!")
      _ -> 
        Api.create_message(msg.channel_id, "Erro desconhecido, estamos trabalhando para resolver o mais rápido possível!")
    end


  end

  defp handleLol(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    nome = Enum.fetch!(aux, 1)

    textoForm = Enum.join(maiusculoTexto(nome), "")

    resp = HTTPoison.get!("https://ddragon.leagueoflegends.com/cdn/12.7.1/data/pt_BR/champion/#{textoForm}.json")

    case resp.status_code != 403 do
      true -> 
        {:ok, map} = Poison.decode(resp.body)
        personagem = map["data"][textoForm]
        Api.create_message(msg.channel_id, "Nome: #{personagem["name"]} | Título: #{personagem["title"]} | Tags: [#{Enum.join(personagem["tags"], ", ")}] \nFrase: #{personagem["lore"]}")
        
      _ -> 
        Api.create_message(msg.channel_id, "O nome #{nome} não foi encontrada. Verifique a grafia ou se realmente esse campeão existe e tente novamente!")
    end

  end

  defp handleValidaCEP(msg) do
    aux = String.split(msg.content)
    cep = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://viacep.com.br/ws/#{cep}/json/")

    
    case resp.status_code != 400 do
      true ->
        {:ok, map} = Poison.decode(resp.body)
        case map["erro"] == nil do
          true -> 
            Api.create_message(msg.channel_id, "#{map["logradouro"]} #{map["complemento"]} | #{map["bairro"]} | #{map["localidade"]}")
          _ -> 
            Api.create_message(msg.channel_id, "CEP não encontrado")
        end
      _ -> 
        Api.create_message(msg.channel_id, "CEP inválido")
    end

  end

  defp handlePassword(msg) do
    resp = HTTPoison.get!("https://passwordinator.herokuapp.com/?num=true&char=true&caps=true&len=18")

    {:ok, map} = Poison.decode(resp.body)

    password = map["data"]
    
    case password != nil do
      true -> 
        Api.create_message(msg.channel_id, "A senha gerada é #{map["data"]}")
      _ -> 
        Api.create_message(msg.channel_id, "Serviço indisponível no momento")
    end

  end

  defp handleDetectLanguage(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    frase = Enum.fetch!(aux, 1)

    resp = HTTPoison.get!("https://ws.detectlanguage.com/0.2/detect?q=#{formatarTexto(frase)}&key=#{Application.fetch_env!(:nostrum, :tokenLanguage)}")

    
    case resp.status_code do
      200 ->
        {:ok, map} = Poison.decode(resp.body)
        detection = Enum.fetch!(map["data"]["detections"], 0)
        Api.create_message(msg.channel_id, "A lingua desse frase é em #{String.upcase(detection["language"])}")

      _ -> 
        Api.create_message(msg.channel_id, "Não conseguimos detectar sua frase, pois possui caracteres que não compreendo.")
    end

  end

  defp handleRickMorty(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    nome = String.downcase(Enum.fetch!(aux, 1))

    resp = HTTPoison.get!("https://rickandmortyapi.com/api/character/?name=#{formatarTexto(nome)}")

    {:ok, map} = Poison.decode(resp.body)

    case map["error"] == nil do
      true ->
        resultados = map["results"]
        personagem = Enum.fetch!(resultados, 0)
        Api.create_message(msg.channel_id, "Nome: #{personagem["name"]}\nStatus: #{personagem["status"]}\nEspécies: #{personagem["species"]}\n#{personagem["image"]}")

      _ -> 
        Api.create_message(msg.channel_id, "O nome #{nome} não foi encontrada. Tente novamente!")
    end
    
  end

  defp handleStoicism(msg) do
    resp = HTTPoison.get!("https://api.themotivate365.com/stoic-quote")

    {:ok, map} = Poison.decode(resp.body)

    info = map["data"]

    Api.create_message(msg.channel_id, "Autor #{info["author"]}: #{info["quote"]}")
  end

  defp handleDog(msg) do
    resp = HTTPoison.get!("https://dog.ceo/api/breeds/image/random")

    {:ok, map} = Poison.decode(resp.body)

    Api.create_message(msg.channel_id, map["message"])
  end

  defp handlePokemon(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    nome = String.downcase(Enum.fetch!(aux, 1))

    resp = HTTPoison.get!("https://pokeapi.co/api/v2/pokemon-form/#{nome}")
    
    case resp.status_code != 404 do
      true -> 
        {:ok, map} = Poison.decode(resp.body)
        pokemon = map["pokemon"]
        Api.create_message(msg.channel_id, "Nome: #{pokemon["name"]}.\n #{map["sprites"]["front_default"]}")
        
      _ -> 
        Api.create_message(msg.channel_id, "O nome #{nome} não foi encontrada. Tente novamente!")
    end

  end

  defp handleCoffee(msg) do
    resp = HTTPoison.get!("https://coffee.alexflipnote.dev/random.json")

    {:ok, map} = Poison.decode(resp.body)

    Api.create_message(msg.channel_id, map["file"])

  end

  defp handleCovid(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    pais = Enum.fetch!(aux, 1)

    paisForm = Enum.join(maiusculoTexto(pais), "%20")

    resp = HTTPoison.get!("https://covid-api.mmediagroup.fr/v1/cases?country=#{paisForm}")

    {:ok, map} = Poison.decode(resp.body)

    case map["All"] != nil do
      true ->
        Api.create_message(msg.channel_id, "Confirmados: #{map["All"]["confirmed"]} | Mortes: #{map["All"]["deaths"]}")
      _ -> 
        Api.create_message(msg.channel_id, "O país #{pais} não foi encontrado. Tente novamente!")

    end
  end

  defp handleNews(msg) do
    aux = String.split(msg.content)
    categoria = Enum.fetch!(aux, 1)
    
    resp = HTTPoison.get!("https://inshortsapi.vercel.app/news?category=#{categoria}")
    
    {:ok, map} = Poison.decode(resp.body)
    
    case map["success"] do
      true -> 
        noticia = Enum.fetch!(map["data"], 0)
        Api.create_message(msg.channel_id, "Author #{noticia["author"]}: #{noticia["content"]}")
      _ -> 
        Api.create_message(msg.channel_id, "A categoria #{categoria} não foi encontrada. Tente novamente!")
    end

  end

  defp handleWeather(msg) do
    aux = String.split(msg.content, " ", parts: 2)
    cidade = Enum.fetch!(aux, 1)
    
    resp = HTTPoison.get!("https://api.openweathermap.org/data/2.5/weather?q=#{cidade}&appid=#{Application.fetch_env!(:nostrum, :tokenWeather)}&units=metric")
    
    {:ok, map} = Poison.decode(resp.body)

    case map["cod"] do
      200 -> 
        temp = map["main"]["temp"]
        Api.create_message(msg.channel_id, "A temperatura da cidade #{cidade} é de #{temp} °C")
      
      "404" -> 
        Api.create_message(msg.channel_id, "A cidade #{cidade} não foi encontrada. Tente novamente!")


    end
  end

  defp handlePPTCommand(msg) do
    aux = String.split(msg.content)
    arg = Enum.fetch!(aux, 1)
    rn = :rand.uniform(3)
    case arg do
      "pedra" -> 
        handleRock(rn, msg)

      "papel" -> 
        handlePaper(rn, msg)

      "tesoura" -> 
        handleScissors(rn, msg)

      _ -> Api.create_message(msg.channel_id, "Argumento inválido!")

    end
  end

  defp handleRock(rn, msg) do
    case rn do
      1 -> Api.create_message(msg.channel_id, "O bot escolheu pedra, houve um empate!")
      2 -> Api.create_message(msg.channel_id, "O bot escolheu papel, o bot ganhou!")
      3 -> Api.create_message(msg.channel_id, "O bot escolheu tesoura, você ganhou!")
    end
  end

  defp handlePaper(rn, msg) do
    case rn do
       1 -> Api.create_message(msg.channel_id, "O bot escolheu pedra, você ganhou!")
          2 -> Api.create_message(msg.channel_id, "O bot escolheu papel, houve um empate!")
          3 -> Api.create_message(msg.channel_id, "O bot escolheu tesoura, o bot ganhou!")
    end
  end

  defp handleScissors(rn, msg) do
    case rn do
      1 -> Api.create_message(msg.channel_id, "O bot escolheu pedra, o bot ganhou!")
      2 -> Api.create_message(msg.channel_id, "O bot escolheu papel, você ganhou!")
      3 -> Api.create_message(msg.channel_id, "O bot escolheu tesoura, houve um empate!")
    end
  end

end
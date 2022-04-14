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


      String.starts_with?(msg.content, "!") -> Api.create_message(msg.channel_id, "Comando inválido, tente novamente!")

      true -> :ignore
    end
  end

  # Funções auxiliares

  defp formatarTexto(texto) do
    aux = String.replace(texto, " ", "%20")

    aux
  end

  def handle_event(_event) do
    :noop
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

    {:ok, map} = Poison.decode(resp.body)

    case map["data"] != nil do
      true ->
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
    
    {:ok, map} = Poison.decode(resp.body)

    case map["error"] != nil do
      true -> 
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
    pais = String.capitalize(Enum.fetch!(aux, 1))

    resp = HTTPoison.get!("https://covid-api.mmediagroup.fr/v1/cases?country=#{pais}")

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
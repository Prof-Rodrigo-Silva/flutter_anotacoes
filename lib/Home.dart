
import 'package:flutter/material.dart';
import 'package:flutter_anotacoes/helper/AnotacaoHelper.dart';
import 'package:flutter_anotacoes/model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = List<Anotacao>();
  Map<String,dynamic> _ultimaAnotacaoRemovida = Map();

  _exibirTelaCadastro( {Anotacao anotacao}){

    String textoSalvarAtualizar ="";
    if( anotacao == null){
      _tituloController.text = "";
      _descricaoController.text="";
      textoSalvarAtualizar = "Salvar";

    }else{
      _tituloController.text = anotacao.titulo;
      _descricaoController.text=anotacao.descricao;
      textoSalvarAtualizar = "Atualizar";
    }
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("$textoSalvarAtualizar anotação"),
            content: ListView(
              //mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Título",
                      hintText: "Digite título..."
                  ),
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Descrição",
                      hintText: "Digite descrição..."
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")
              ),
              FlatButton(
                  onPressed: (){
                    //salvar
                    _salvarAtualizarAnotacao(anotacaoSelecionada: anotacao);
                    Navigator.pop(context);
                  },
                  child: Text(textoSalvarAtualizar)
              )
            ],
          );
        }
    );

  }

  _recuperarAnotacaos() async{
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao> listaTemporaria = List<Anotacao>();
    for( var item in anotacoesRecuperadas){

      Anotacao anotacao = Anotacao.fromMapp(item);
      listaTemporaria.add( anotacao );

    }
    setState(() {
      _anotacoes = listaTemporaria;
    });
    listaTemporaria = null;
  }

  _salvarAtualizarAnotacao({Anotacao anotacaoSelecionada}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if( anotacaoSelecionada == null){
      Anotacao anotacao = Anotacao(titulo,descricao,DateTime.now().toString());
      int i = await _db.salvarAnotacao(anotacao);

    }else{
      anotacaoSelecionada.titulo = titulo;
      anotacaoSelecionada.descricao = descricao;
      anotacaoSelecionada.data = DateTime.now().toString();

      int i = await _db.atualizarAnotacao( anotacaoSelecionada );

      }
    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacaos();

  }

  _salvarAnotacaoSnack(Anotacao ultimaAnotacaoRemovida) async{
    Anotacao anotacao = Anotacao(ultimaAnotacaoRemovida.titulo,ultimaAnotacaoRemovida.descricao,DateTime.now().toString());
    int i = await _db.salvarAnotacaoSnackBar(anotacao);
    _recuperarAnotacaos();

  }

  _removerAnotacao(int id) async{
    await _db.removerAnotacao(id);
    _recuperarAnotacaos();
  }

  _formatarData(String data){

    initializeDateFormatting("pt_BR");
    var formatador = DateFormat("d/MM/y H:m:s");
    //var formatador = DateFormat.yMMMMd("pt_BR");
    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarAnotacaos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Minhas anotações"),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                  itemCount: _anotacoes.length,
                  itemBuilder: (context,index){
                    final anotacao = _anotacoes[index];
                    return
                      Dismissible(
                        background: Container(
                        color: Colors.red,
                        padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.delete,
                                color: Colors.white,)
                            ],
                          ),
                        ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction){

                            Anotacao _ultimaAnotacaoRemovida = anotacao;
                            _removerAnotacao(anotacao.id);
                            final snackbar = SnackBar(
                                content: Text("Removido!"),
                                duration: Duration(seconds: 5),
                                action: SnackBarAction(
                                  label: "Desfazer",
                                  onPressed: (){
                                    _salvarAnotacaoSnack(_ultimaAnotacaoRemovida);
                                  },
                                ),
                            );
                            Scaffold.of(context).showSnackBar(snackbar);
                          },
                          key: Key(DateTime.now().millisecondsSinceEpoch.toString()),

                                child: Card(
                                 child: ListTile(
                                    title: Text(anotacao.titulo),
                                    subtitle: Text(""
                                        "${_formatarData(anotacao.data)} - "
                                        "${anotacao.descricao}"),
                                   trailing: Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: <Widget>[
                                       GestureDetector(
                                         onTap: (){
                                           _exibirTelaCadastro(anotacao: anotacao);
                                         },
                                         child: Padding(
                                           padding: EdgeInsets.only(
                                               top: 16,
                                               bottom: 16,
                                               left: 5,
                                               right: 5),
                                           child: Icon(Icons.edit,
                                              color: Colors.blue,
                                            ),
                                        ),
                                       ),
                                       GestureDetector(
                                         onTap: (){
                                           _removerAnotacao(anotacao.id);
                                         },
                                         child: Padding(
                                           padding: EdgeInsets.only(
                                               top: 16,
                                               bottom: 16,
                                               left: 5,
                                               right: 5),
                                           child: Icon(Icons.delete,
                                             color: Colors.red,
                                           ),
                                         ),
                                       )
                                     ],
                                   ),
                                 ),
                                )
                      );
                  }
                  )
          )

        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: (){
            _exibirTelaCadastro();
          }
      ),
    );
  }
}

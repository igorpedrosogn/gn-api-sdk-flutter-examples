import 'package:examplesgn/components/loading.dart';
import 'package:examplesgn/credentials.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gerencianet/gerencianet.dart';

class PixListReceived extends StatefulWidget {
  @override
  _PixListReceivedState createState() => _PixListReceivedState();
}

class _PixListReceivedState extends State<PixListReceived> {
  Gerencianet gn;

  @override
  void initState() {
    super.initState();
    gn = new Gerencianet(CREDENTIALS);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _appBar(),
        backgroundColor: Theme.of(context).backgroundColor,
        body: SingleChildScrollView(
          child: _body(),
        ));
  }

  Widget _body() {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return _error();
        else if (snapshot.hasData)
          return snapshot.data['pix'].length > 0
              ? _list(snapshot)
              : _notFound();
        else
          return _loading();
      },
      future: gn.call('pixListReceived', params: {
        "inicio": "2021-01-01T16:01:35Z",
        "fim": "2021-12-31T16:01:35Z"
      }),
    );
  }

  Widget _list(snapshot) {
    return ListView.builder(
        itemCount: snapshot.data['pix'].length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          return _content(snapshot.data['pix'], index);
        });
  }

  Widget _content(info, index) {
    return Padding(
        padding: EdgeInsets.only(bottom: 7.5, top: 7.5),
        child: ListTile(
            contentPadding:
                EdgeInsets.only(bottom: 7.5, top: 7.5, left: 15, right: 15),
            title: Text(info[index]['endToEndId'],
                style: TextStyle(fontSize: 15),
                overflow: TextOverflow.ellipsis),
            subtitle:
                Text(info[index]['chave'], overflow: TextOverflow.ellipsis),
            trailing: Text("R\$ \n ${info[index]['valor']}",
                style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
            tileColor: Colors.white,
            leading: Container(
              width: 45,
              child: IconButton(
                onPressed: () {
                  _showInfoDetail(info[index]);
                },
                icon: Icon(Icons.remove_red_eye,
                    color: Theme.of(context).accentColor),
              ),
            )));
  }

  Widget _loading() {
    return Container(
      height: MediaQuery.of(context).size.height - 150,
      child: Center(child: Loading()),
    );
  }

  Widget _notFound() {
    return Container(
      height: MediaQuery.of(context).size.height - 150,
      child: Center(
        child: Text(
          "Nenhum dado encontrado!",
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
      ),
    );
  }

  Widget _error() {
    return Container(
      height: MediaQuery.of(context).size.height - 150,
      child: Center(
        child: Text(
          "Aconteceu um erro!",
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buttonInfo(String title, String content, Color color) {
    return IconButton(
        icon: Icon(Icons.help, color: color),
        onPressed: () {
          _showInfo(title, content);
        });
  }

  Widget _appBar() {
    return AppBar(
      elevation: 0,
      title: Text("PIX Recebidos"),
      centerTitle: true,
      actions: [
        _buttonInfo(
            "Consultar Pix recebidos",
            "Endpoint para consultar Pix recebidos GET /v2/pix​/.\n\n",
            Colors.white)
      ],
    );
  }

  void _showInfo(String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).backgroundColor,
            title: new Text(title),
            content: Text(content +
                "\n\nPara mais informações acesse a nossa documentação: dev.gerencianet.com.br"),
            contentTextStyle: TextStyle(color: Color(0xFF848484)),
            titleTextStyle:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 18),
            actions: <Widget>[
              new TextButton(
                child: new Text(
                  "Fechar",
                  style: TextStyle(color: Theme.of(context).accentColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _showInfoDetail(value) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                elevation: 0,
                title:
                    Text(value['endToEndId'], style: TextStyle(fontSize: 15)),
                centerTitle: true,
                actions: [
                  value.containsKey('devolucoes')
                      ? IconButton(
                          icon: Icon(Icons.monetization_on_outlined),
                          onPressed: () {
                            _showDevolutions(value['devolucoes']);
                          })
                      : Container()
                ],
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _infoCharge(
                        "${value['endToEndId']}", "ENDTOENDID", true),
                    _infoCharge("${value['valor']}", "VALOR", true),
                    _infoCharge("${value['chave']}", "CHAVE", true),
                    _infoCharge("${value['horario']}", "HORÁRIO", false),
                  ],
                ),
              ));
        });
  }

  void _showDevolutions(value) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                elevation: 0,
                title: Text("Devoluções"),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var devolution in value)
                      Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Column(
                          children: [
                            _infoCharge(
                                "${devolution['id'].toString()}", "ID", true),
                            _infoCharge(
                                "${devolution['valor']}", "VALOR", true),
                            _infoCharge(
                                "${devolution['status']}", "STATUS", false),
                            _infoCharge(
                                "${devolution['rtrId']}", "RTRID", false),
                            _infoCharge(
                                "${devolution['horario']['solicitacao']}",
                                "SOLICITAÇÃO",
                                false),
                            _infoCharge(
                                "${devolution['horario']['liquidacao']}",
                                "LIQUIDAÇÃO",
                                false),
                            Divider(
                              color: Theme.of(context).primaryColor,
                              height: 2,
                            )
                          ],
                        ),
                      )
                  ],
                ),
              ));
        });
  }

  Widget _infoCharge(String info, String name, bool show) {
    return ListTile(
      title: Text(info),
      subtitle: Text(name),
      leading: Container(
          width: 45,
          child: show
              ? IconButton(
                  onPressed: () async {
                    ClipboardData data = ClipboardData(text: info);
                    await Clipboard.setData(data);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Theme.of(context).accentColor,
                      content: Text("Informação copiada"),
                    ));
                  },
                  icon: Icon(Icons.copy, color: Theme.of(context).accentColor),
                )
              : Container()),
    );
  }
}
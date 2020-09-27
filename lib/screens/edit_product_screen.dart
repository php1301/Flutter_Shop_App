import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/product_p.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController =
      TextEditingController(); // Su dung cai nay chi khi can value 1 field nao do vao 1 logic phuc tap khac nhu su dung cho field khac
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  var _isInit = true; // tranh didChangeDependencies run mutiple times
  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(
        _updateImageUrl); // bat dau lang nghe va goi check focus (can 1 functionde lang nghe), lang nghe su kien co focus khong
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode
        .removeListener(_updateImageUrl); // Goi khi dispose removeListener
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      // Validate chan setState, set khi isEmpty
      if (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https') ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) return;
      setState(() {}); // rebuild UI trigger dispose
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) return;
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (e) {
        await showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            actions: [
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
            title: Text('Something went wrong'),
          ),
        );
      }
      //  finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }
  // void _saveForm() {
  //   final isValid = _form.currentState.validate();
  //   if (!isValid) return;
  //   _form.currentState.save();
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   if (_editedProduct.id != null) {
  //     Provider.of<Products>(context, listen: false)
  //         .updateProduct(_editedProduct.id, _editedProduct);
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   } else {
  //     Provider.of<Products>(context, listen: false)
  //         .addProduct(_editedProduct)
  //         .catchError(
  //           (e) => showDialog<Null>(
  //             context: context,
  //             builder: (ctx) => AlertDialog(
  //               actions: [
  //                 FlatButton(
  //                   child: Text('Okay'),
  //                   onPressed: () {
  //                     Navigator.of(ctx).pop();
  //                   },
  //                 )
  //               ],
  //               title: Text('Something went wrong'),
  //             ),
  //           ),
  //         )
  //         .then((_) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       Navigator.of(context).pop();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: InputDecoration(
                          labelText: 'Title',
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) return 'Please provide a title.';
                          return null; // Correct input
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: value,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            description: _editedProduct.description,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                      ), //.next move to next input
                      TextFormField(
                        initialValue: _initValues['price'],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price',
                        ),
                        focusNode: _priceFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) return 'Please enter a price';
                          if (double.tryParse(value) == null)
                            return 'Please enter a valid number';
                          if (double.parse(value) <= 0)
                            return 'Please enter a price greater than 0';
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: _editedProduct.title,
                            price: double.parse(value),
                            imageUrl: _editedProduct.imageUrl,
                            description: _editedProduct.description,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                      ), //.next move to next input
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 3, //special value null
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Please enter a description';
                          if (value.length < 10)
                            return 'Please enter a description longer than 10';
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            description: value,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter a Url')
                                : FittedBox(
                                    child:
                                        Image.network(_imageUrlController.text),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              // initialValue: _initValues['imageUrl'],
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              onEditingComplete: () {
                                setState(() {});
                              },
                              validator: (value) {
                                if (value.isEmpty)
                                  return 'Please enter a Image Url';
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https'))
                                  return 'Please enter a valid URL';
                                if (!value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg'))
                                  return 'Please enter a valid URL format';
                                return null;
                              },
                              onSaved: (value) {
                                _editedProduct = Product(
                                  title: _editedProduct.title,
                                  price: _editedProduct.price,
                                  imageUrl: value,
                                  description: _editedProduct.description,
                                  id: _editedProduct.id,
                                  isFavorite: _editedProduct.isFavorite,
                                );
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}

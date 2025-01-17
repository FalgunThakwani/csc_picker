import 'package:flutter/material.dart';

class DropdownWithSearch<T> extends StatelessWidget {
  final String title;
  final String placeHolder;
  final T selected;
  final List items;
  final TextStyle titleStyle;
  final TextStyle itemStyle;
  final bool disabled;

  final Function onChanged;

  const DropdownWithSearch(
      {Key key,
      @required this.title,
      @required this.placeHolder,
      @required this.items,
      @required this.selected,
      @required this.onChanged,
      this.titleStyle,
      this.itemStyle,
      this.disabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: disabled,
      child: InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => SearchDialog(
                  placeHolder: placeHolder,
                  title: title,
                  items: items)).then((value) {
            onChanged(value);
          });
        },
        child:Container(
          height: 40,
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              color: Color.fromARGB(255,218, 146, 178),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                selected.toString(),
                style:TextStyle(color:Colors.white),
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchDialog extends StatefulWidget {
  final String title;
  final String placeHolder;
  final List items;
  final TextStyle titleStyle;
  final TextStyle itemStyle;

  const SearchDialog(
      {Key key,
      @required this.title,
      @required this.placeHolder,
      @required this.items,
      this.titleStyle,
      this.itemStyle})
      : super(key: key);

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState<T> extends State<SearchDialog> {
  TextEditingController textController = TextEditingController();
  List filteredList;

  @override
  void initState() {
    filteredList = widget.items;
    textController.addListener(() {
      setState(() {
        if (textController.text.isEmpty) {
          filteredList = widget.items;
        } else {
          filteredList = widget.items
              .where((element) => element
                  .toString()
                  .toLowerCase()
                  .contains(textController.text.toLowerCase()))
              .toList();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: widget.titleStyle != null
                  ? widget.titleStyle
                  : TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.search),
                hintText: widget.placeHolder,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: const BorderSide(
                    color: Colors.black26,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
              ),
              style: widget.itemStyle != null
                  ? widget.titleStyle
                  : TextStyle(fontSize: 14),
              controller: textController,
            ),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context, filteredList[index]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              filteredList[index].toString(),
                              style: widget.itemStyle != null
                                  ? widget.titleStyle
                                  : TextStyle(fontSize: 14),
                            ),
                          ));
                    }),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'CLOSE',
                    style: widget.titleStyle != null
                        ? widget.titleStyle
                        : TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  )),
            )
          ],
        ),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  /// Creates a dialog.
  ///
  /// Typically used in conjunction with [showDialog].
  const CustomDialog({
    Key key,
    this.child,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetAnimationCurve = Curves.decelerate,
    this.shape,
    this.constraints = const BoxConstraints(minWidth: 280.0),
  }) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// The duration of the animation to show when the system keyboard intrudes
  /// into the space that the dialog is placed in.
  ///
  /// Defaults to 100 milliseconds.
  final Duration insetAnimationDuration;

  /// The curve to use for the animation shown when the system keyboard intrudes
  /// into the space that the dialog is placed in.
  ///
  /// Defaults to [Curves.fastOutSlowIn].
  final Curve insetAnimationCurve;

  /// {@template flutter.material.dialog.shape}
  /// The shape of this dialog's border.
  ///
  /// Defines the dialog's [Material.shape].
  ///
  /// The default shape is a [RoundedRectangleBorder] with a radius of 2.0.
  /// {@endtemplate}
  final ShapeBorder shape;
  final BoxConstraints constraints;

  Color _getColor(BuildContext context) {
    return Theme.of(context).dialogBackgroundColor;
  }

  // TODO(johnsonmh): Update default dialog border radius to 4.0 to match material spec.
  static const RoundedRectangleBorder _defaultDialogShape =
      RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)));

  @override
  Widget build(BuildContext context) {
    final DialogTheme dialogTheme = DialogTheme.of(context);
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
      duration: insetAnimationDuration,
      curve: insetAnimationCurve,
      child: MediaQuery.removeViewInsets(
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: Center(
          child: ConstrainedBox(
            constraints: constraints,
            child: Material(
              elevation: 15.0,
              color: _getColor(context),
              type: MaterialType.card,
              child: child,
              shape: shape ?? dialogTheme.shape ?? _defaultDialogShape,
            ),
          ),
        ),
      ),
    );
  }
}

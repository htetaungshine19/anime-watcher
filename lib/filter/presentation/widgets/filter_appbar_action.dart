import 'package:animely/filter/presentation/filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget filterAppbarAction(BuildContext context, void Function() onSubmit) {
  return IconButton(
      tooltip: "filter",
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Consumer(builder: (context, w, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                      child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Keyword",
                          ),
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            context.read(filterProvider).keyword = value;
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Consumer(
                        builder: (context, watch, child) {
                          return Text(watch(filterProvider).keyword.isEmpty
                              ? "default"
                              : watch(filterProvider).keyword);
                        },
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                    ],
                  )),
                  Expanded(
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        DropdownButton(
                            hint: const Text("year"),
                            onChanged: (value) {
                              context.read(filterProvider).year =
                                  value as String;
                            },
                            items: const [
                              DropdownMenuItem(
                                child: Text("2000"),
                                value: "2000",
                              ),
                              DropdownMenuItem(
                                child: Text("2001"),
                                value: "2001",
                              ),
                              DropdownMenuItem(
                                child: Text("2002"),
                                value: "2002",
                              ),
                              DropdownMenuItem(
                                child: Text("2003"),
                                value: "2003",
                              ),
                              DropdownMenuItem(
                                child: Text("2004"),
                                value: "2004",
                              ),
                              DropdownMenuItem(
                                child: Text("2005"),
                                value: "2005",
                              ),
                              DropdownMenuItem(
                                child: Text("2006"),
                                value: "2006",
                              ),
                              DropdownMenuItem(
                                child: Text("2007"),
                                value: "2007",
                              ),
                              DropdownMenuItem(
                                child: Text("2008"),
                                value: "2008",
                              ),
                              DropdownMenuItem(
                                child: Text("2009"),
                                value: "2009",
                              ),
                              DropdownMenuItem(
                                child: Text("2010"),
                                value: "2010",
                              ),
                              DropdownMenuItem(
                                child: Text("2011"),
                                value: "2011",
                              ),
                              DropdownMenuItem(
                                child: Text("2012"),
                                value: "2012",
                              ),
                              DropdownMenuItem(
                                child: Text("2013"),
                                value: "2013",
                              ),
                              DropdownMenuItem(
                                child: Text("2014"),
                                value: "2014",
                              ),
                              DropdownMenuItem(
                                child: Text("2015"),
                                value: "2015",
                              ),
                              DropdownMenuItem(
                                child: Text("2016"),
                                value: "2016",
                              ),
                              DropdownMenuItem(
                                child: Text("2017"),
                                value: "2017",
                              ),
                              DropdownMenuItem(
                                child: Text("2018"),
                                value: "2018",
                              ),
                              DropdownMenuItem(
                                child: Text("2019"),
                                value: "2019",
                              ),
                              DropdownMenuItem(
                                child: Text("2020"),
                                value: "2020",
                              ),
                              DropdownMenuItem(
                                child: Text("2021"),
                                value: "2021",
                              ),
                              DropdownMenuItem(
                                child: Text("2022"),
                                value: "2022",
                              ),
                              DropdownMenuItem(
                                child: Text("2023"),
                                value: "2023",
                              ),
                            ]),
                        const Spacer(),
                        Consumer(
                          builder: (context, watch, child) {
                            return Text(watch(filterProvider).year.isEmpty
                                ? "default"
                                : watch(filterProvider).year);
                          },
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        DropdownButton(
                            onChanged: (value) {
                              context.read(filterProvider).seasons =
                                  value as String;
                            },
                            hint: const Text("Seasons"),
                            items: const [
                              DropdownMenuItem(
                                child: Text("WINTER"),
                                value: "0",
                              ),
                              DropdownMenuItem(
                                child: Text("SPRING"),
                                value: "1",
                              ),
                              DropdownMenuItem(
                                child: Text("SUMMER"),
                                value: "2",
                              ),
                              DropdownMenuItem(
                                child: Text("FALL"),
                                value: "3",
                              ),
                              DropdownMenuItem(
                                child: Text("UNKNOWN"),
                                value: "4",
                              ),
                            ]),
                        const Spacer(),
                        Consumer(
                          builder: (context, watch, child) {
                            final t = watch(filterProvider).seasons;
                            if (t == "0") {
                              return const Text("WINTER");
                            }
                            if (t == "1") {
                              return const Text("SPRING");
                            }
                            if (t == "2") {
                              return const Text("SUMMER");
                            }
                            if (t == "3") {
                              return const Text("FALL");
                            }
                            if (t == "4") {
                              return const Text("UNKNOWN");
                            }
                            return const Text("default");
                          },
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        DropdownButton(
                            onChanged: (value) {
                              context.read(filterProvider).format =
                                  value as String;
                            },
                            hint: const Text("Formats"),
                            items: const [
                              DropdownMenuItem(
                                child: Text("TV"),
                                value: "0",
                              ),
                              DropdownMenuItem(
                                child: Text("TV_SHORT"),
                                value: "1",
                              ),
                              DropdownMenuItem(
                                child: Text("MOVIE"),
                                value: "2",
                              ),
                              DropdownMenuItem(
                                child: Text("SPECIAL"),
                                value: "3",
                              ),
                              DropdownMenuItem(
                                child: Text("OVA"),
                                value: "4",
                              ),
                            ]),
                        const Spacer(),
                        Consumer(
                          builder: (context, watch, child) {
                            final t = watch(filterProvider).format;
                            if (t == "0") {
                              return const Text("TV");
                            }
                            if (t == "1") {
                              return const Text("TV_SHORT");
                            }
                            if (t == "2") {
                              return const Text("MOVIE");
                            }
                            if (t == "3") {
                              return const Text("SPECIAL");
                            }
                            if (t == "4") {
                              return const Text("OVA");
                            }
                            return const Text("default");
                          },
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        DropdownButton(
                            onChanged: (value) {
                              context.read(filterProvider).status =
                                  value as String;
                            },
                            hint: const Text("Status"),
                            items: const [
                              DropdownMenuItem(
                                child: Text("FINISHED"),
                                value: "0",
                              ),
                              DropdownMenuItem(
                                child: Text("RELEASING"),
                                value: "1",
                              ),
                              DropdownMenuItem(
                                child: Text("NOT_YET_RELEASED"),
                                value: "2",
                              ),
                              DropdownMenuItem(
                                child: Text("CANCELLED"),
                                value: "3",
                              ),
                            ]),
                        const Spacer(),
                        Consumer(
                          builder: (context, watch, child) {
                            final t = watch(filterProvider).status;
                            if (t == "0") {
                              return const Text("FINISHED");
                            }
                            if (t == "1") {
                              return const Text("RELEASING");
                            }
                            if (t == "2") {
                              return const Text("NOT_YET_RELEASED");
                            }
                            if (t == "3") {
                              return const Text("CANCELLED");
                            }

                            return const Text("default");
                          },
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read(filterProvider).reset();
                        },
                        child: const Text("reset"),
                      ),
                      ElevatedButton(
                        child: const Text("submit"),
                        onPressed: () async {
                          onSubmit();
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                ],
              );
            });
          },
        );
      },
      icon: const Icon(Icons.filter_alt));
}

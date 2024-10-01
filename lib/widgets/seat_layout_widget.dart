
import 'package:flutter/material.dart';
import 'package:pinnket/widgets/seat_widget.dart';

import '../models/seat_layout_state_model.dart';
import '../models/seat_model.dart';
import '../utils/seat_state.dart';

class SeatLayoutWidget extends StatelessWidget {
  final SeatLayoutStateModel stateModel;
  final void Function(int rowI, int colI, SeatState currentState)
      onSeatStateChanged;

  const SeatLayoutWidget({
    super.key,
    required this.stateModel,
    required this.onSeatStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      maxScale: 5,
      minScale: 0.8,
      boundaryMargin: const EdgeInsets.all(8),
      constrained: true,
      child: Column(
        children: [
          ...List<int>.generate(stateModel.rows, (rowI) => rowI)
              .map<Row>(
                (rowI) => Row(
                  children: [
                    ...List<int>.generate(stateModel.cols, (colI) => colI)
                        .map<SeatWidget>((colI) => SeatWidget(
                              model: SeatModel(
                                seatState: stateModel.currentSeatsState[rowI]
                                    [colI],
                                rowI: rowI,
                                colI: colI,
                                seatSvgSize: stateModel.seatSvgSize,
                                pathSelectedSeat: stateModel.pathSelectedSeat,
                                pathDisabledSeat: stateModel.pathDisabledSeat,
                                pathSoldSeat: stateModel.pathSoldSeat,
                                pathUnSelectedSeat:
                                    stateModel.pathUnSelectedSeat,
                              ),
                              onSeatStateChanged: onSeatStateChanged,
                            ))

                  ],
                ),
              )

        ],
      ),
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubTaskAdapter extends TypeAdapter<SubTask> {
  @override
  final int typeId = 2;

  @override
  SubTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubTask(
      id: fields[0] as String?,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SubTask obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 3;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String,
      isCompleted: fields[3] as bool,
      dueDate: fields[4] as DateTime?,
      categoryId: fields[5] as String,
      priority: fields[6] as TaskPriority,
      subTasks: (fields[7] as List?)?.cast<SubTask>(),
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.categoryId)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.subTasks)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityAdapter extends TypeAdapter<TaskPriority> {
  @override
  final int typeId = 1;

  @override
  TaskPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriority.high;
      case 1:
        return TaskPriority.medium;
      case 2:
        return TaskPriority.low;
      default:
        return TaskPriority.high;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriority obj) {
    switch (obj) {
      case TaskPriority.high:
        writer.writeByte(0);
        break;
      case TaskPriority.medium:
        writer.writeByte(1);
        break;
      case TaskPriority.low:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

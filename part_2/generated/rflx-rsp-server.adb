--
-- Generated by RecordFlux 0.9.1.dev18+ge578157d on 2023-05-09
--
-- Copyright (C) 2018-2023 AdaCore GmbH
--
-- This file is distributed under the terms of the GNU Affero General Public License version 3.
--

pragma Restrictions (No_Streams);
pragma Style_Checks ("N3aAbCdefhiIklnOprStux");
pragma Warnings (Off, "redundant conversion");

package body RFLX.RSP.Server with
  SPARK_Mode
is

   use type RFLX.RFLX_Types.Bytes_Ptr;

   use type RFLX.RFLX_Types.Bit_Length;

   procedure Receive_Request (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Receive_Request_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Receive_Request_Invariant);
      -- rsp.rflx:79:10
      RSP.RSP_Message.Verify_Message (Ctx.P.Request_Ctx);
      if RSP.RSP_Message.Well_Formed_Message (Ctx.P.Request_Ctx) = False then
         Ctx.P.Next_State := S_Invalid_Packet_Error;
      elsif RSP.RSP_Message.Get_Kind (Ctx.P.Request_Ctx) /= Request_Msg then
         Ctx.P.Next_State := S_Got_Answer_Packet_Error;
      elsif RSP.RSP_Message.Get_Request_Kind (Ctx.P.Request_Ctx) = Request_Store then
         Ctx.P.Next_State := S_Store;
      elsif RSP.RSP_Message.Get_Request_Kind (Ctx.P.Request_Ctx) = Request_Get then
         Ctx.P.Next_State := S_Get;
      else
         Ctx.P.Next_State := S_Exception_Error;
      end if;
      pragma Assert (Receive_Request_Invariant);
   end Receive_Request;

   procedure Store (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      St_Result : RSP.Store_Result;
      function Store_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Store_Invariant);
      -- rsp.rflx:91:10
      if
         RSP.RSP_Message.Valid (Ctx.P.Request_Ctx, RSP.RSP_Message.F_Request_Stack_Id)
         and then RSP.RSP_Message.Well_Formed (Ctx.P.Request_Ctx, RSP.RSP_Message.F_Request_Payload_Data)
      then
         declare
            RFLX_Store_Data_Arg_1_Request : RFLX_Types.Bytes (RFLX_Types.Index'First .. RFLX_Types.Index'First + 4095) := (others => 0);
            RFLX_Store_Data_Arg_1_Request_Length : constant RFLX_Types.Length := RFLX_Types.To_Length (RSP.RSP_Message.Field_Size (Ctx.P.Request_Ctx, RSP.RSP_Message.F_Request_Payload_Data)) + 1;
         begin
            RSP.RSP_Message.Get_Request_Payload_Data (Ctx.P.Request_Ctx, RFLX_Store_Data_Arg_1_Request (RFLX_Types.Index'First .. RFLX_Types.Index'First + RFLX_Types.Index (RFLX_Store_Data_Arg_1_Request_Length) - 2));
            Store_Data (Ctx, RSP.RSP_Message.Get_Request_Stack_Id (Ctx.P.Request_Ctx), RFLX_Store_Data_Arg_1_Request (RFLX_Types.Index'First .. RFLX_Types.Index'First + RFLX_Types.Index (RFLX_Store_Data_Arg_1_Request_Length) - 2), St_Result);
         end;
      else
         Ctx.P.Next_State := S_Exception_Error;
         pragma Assert (Store_Invariant);
         goto Finalize_Store;
      end if;
      if St_Result = Store_Fail then
         Ctx.P.Next_State := S_Stack_Full_Error;
      else
         Ctx.P.Next_State := S_Answer_Success;
      end if;
      pragma Assert (Store_Invariant);
      <<Finalize_Store>>
   end Store;

   procedure Answer_Success (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Answer_Success_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Answer_Success_Invariant);
      -- rsp.rflx:102:10
      Ctx.P.Result := Ok;
      Ctx.P.Next_State := S_Setup_Answer;
      pragma Assert (Answer_Success_Invariant);
   end Answer_Success;

   procedure Get (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      Payload : RSP.Payload.Structure;
      function Get_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Get_Invariant);
      -- rsp.rflx:110:10
      Get_Data (Ctx, RSP.RSP_Message.Get_Request_Stack_Id (Ctx.P.Request_Ctx), Payload);
      if not RSP.Payload.Valid_Structure (Payload) then
         Ctx.P.Next_State := S_Exception_Error;
         pragma Assert (Get_Invariant);
         goto Finalize_Get;
      end if;
      -- rsp.rflx:111:10
      RSP.RSP_Message.Reset (Ctx.P.Answer_Ctx);
      if RSP.RSP_Message.Available_Space (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Kind) < RSP.Payload.Field_Size_Data (Payload) + 24 then
         Ctx.P.Next_State := S_Exception_Error;
         pragma Assert (Get_Invariant);
         goto Finalize_Get;
      end if;
      pragma Assert (RSP.RSP_Message.Sufficient_Space (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Kind));
      RSP.RSP_Message.Set_Kind (Ctx.P.Answer_Ctx, Answer_Msg);
      pragma Assert (RSP.RSP_Message.Sufficient_Space (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Answer_Kind));
      RSP.RSP_Message.Set_Answer_Kind (Ctx.P.Answer_Ctx, Answer_Data);
      RSP.RSP_Message.Set_Answer_Payload_Length (Ctx.P.Answer_Ctx, Payload.Length);
      if RSP.RSP_Message.Valid_Length (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Answer_Payload_Data, RFLX_Types.To_Length (RSP.Payload.Field_Size_Data (Payload))) then
         declare
            function RFLX_Process_Data_Pre (Length : RFLX_Types.Length) return Boolean is
              (RSP.Payload.Valid_Structure (Payload)
               and then Length = RFLX_Types.To_Length (RSP.Payload.Field_Size_Data (Payload)));
            procedure RFLX_Process_Data (Data : out RFLX_Types.Bytes) with
              Pre =>
                RFLX_Process_Data_Pre (Data'Length)
            is
            begin
               Data := Payload.Data (Payload.Data'First .. Payload.Data'First + Data'Length - 1);
            end RFLX_Process_Data;
            procedure RFLX_RSP_RSP_Message_Set_Answer_Payload_Data is new RSP.RSP_Message.Generic_Set_Answer_Payload_Data (RFLX_Process_Data, RFLX_Process_Data_Pre);
         begin
            RFLX_RSP_RSP_Message_Set_Answer_Payload_Data (Ctx.P.Answer_Ctx, RFLX_Types.To_Length (RSP.Payload.Field_Size_Data (Payload)));
         end;
      else
         Ctx.P.Next_State := S_Exception_Error;
         pragma Assert (Get_Invariant);
         goto Finalize_Get;
      end if;
      Ctx.P.Next_State := S_Send_Data_Answer;
      pragma Assert (Get_Invariant);
      <<Finalize_Get>>
   end Get;

   procedure Send_Data_Answer (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Send_Data_Answer_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Send_Data_Answer_Invariant);
      -- rsp.rflx:123:10
      Ctx.P.Next_State := S_Receive_Request;
      pragma Assert (Send_Data_Answer_Invariant);
   end Send_Data_Answer;

   procedure Exception_Error (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Exception_Error_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Exception_Error_Invariant);
      -- rsp.rflx:130:10
      Ctx.P.Result := Got_Exception;
      Ctx.P.Next_State := S_Setup_Answer;
      pragma Assert (Exception_Error_Invariant);
   end Exception_Error;

   procedure Invalid_Packet_Error (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Invalid_Packet_Error_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Invalid_Packet_Error_Invariant);
      -- rsp.rflx:137:10
      Ctx.P.Result := Invalid_Packet;
      Ctx.P.Next_State := S_Setup_Answer;
      pragma Assert (Invalid_Packet_Error_Invariant);
   end Invalid_Packet_Error;

   procedure Got_Answer_Packet_Error (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Got_Answer_Packet_Error_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Got_Answer_Packet_Error_Invariant);
      -- rsp.rflx:144:10
      Ctx.P.Result := Got_Answer_Packet;
      Ctx.P.Next_State := S_Setup_Answer;
      pragma Assert (Got_Answer_Packet_Error_Invariant);
   end Got_Answer_Packet_Error;

   procedure Stack_Full_Error (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Stack_Full_Error_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Stack_Full_Error_Invariant);
      -- rsp.rflx:151:10
      Ctx.P.Result := Stack_Full;
      Ctx.P.Next_State := S_Setup_Answer;
      pragma Assert (Stack_Full_Error_Invariant);
   end Stack_Full_Error;

   procedure Setup_Answer (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Setup_Answer_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Setup_Answer_Invariant);
      -- rsp.rflx:158:10
      RSP.RSP_Message.Reset (Ctx.P.Answer_Ctx);
      if RSP.RSP_Message.Available_Space (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Kind) < 24 then
         Ctx.P.Next_State := S_Final;
         pragma Assert (Setup_Answer_Invariant);
         goto Finalize_Setup_Answer;
      end if;
      pragma Assert (RSP.RSP_Message.Sufficient_Space (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Kind));
      RSP.RSP_Message.Set_Kind (Ctx.P.Answer_Ctx, Answer_Msg);
      pragma Assert (RSP.RSP_Message.Sufficient_Space (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Answer_Kind));
      RSP.RSP_Message.Set_Answer_Kind (Ctx.P.Answer_Ctx, Answer_Result);
      pragma Assert (RSP.RSP_Message.Sufficient_Space (Ctx.P.Answer_Ctx, RSP.RSP_Message.F_Answer_Server_Result));
      RSP.RSP_Message.Set_Answer_Server_Result (Ctx.P.Answer_Ctx, Ctx.P.Result);
      Ctx.P.Next_State := S_Send_Answer;
      pragma Assert (Setup_Answer_Invariant);
      <<Finalize_Setup_Answer>>
   end Setup_Answer;

   procedure Send_Answer (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
      function Send_Answer_Invariant return Boolean is
        (Ctx.P.Slots.Slot_Ptr_1 = null
         and Ctx.P.Slots.Slot_Ptr_2 = null)
       with
        Annotate =>
          (GNATprove, Inline_For_Proof),
        Ghost;
   begin
      pragma Assert (Send_Answer_Invariant);
      -- rsp.rflx:169:10
      Ctx.P.Next_State := S_Receive_Request;
      pragma Assert (Send_Answer_Invariant);
   end Send_Answer;

   procedure Initialize (Ctx : in out Context'Class) is
      Request_Buffer : RFLX_Types.Bytes_Ptr;
      Answer_Buffer : RFLX_Types.Bytes_Ptr;
   begin
      RSP.Server_Allocator.Initialize (Ctx.P.Slots, Ctx.P.Memory);
      Request_Buffer := Ctx.P.Slots.Slot_Ptr_1;
      pragma Warnings (Off, "unused assignment");
      Ctx.P.Slots.Slot_Ptr_1 := null;
      pragma Warnings (On, "unused assignment");
      RSP.RSP_Message.Initialize (Ctx.P.Request_Ctx, Request_Buffer);
      Answer_Buffer := Ctx.P.Slots.Slot_Ptr_2;
      pragma Warnings (Off, "unused assignment");
      Ctx.P.Slots.Slot_Ptr_2 := null;
      pragma Warnings (On, "unused assignment");
      RSP.RSP_Message.Initialize (Ctx.P.Answer_Ctx, Answer_Buffer);
      Ctx.P.Next_State := S_Receive_Request;
   end Initialize;

   procedure Finalize (Ctx : in out Context'Class) is
      Request_Buffer : RFLX_Types.Bytes_Ptr;
      Answer_Buffer : RFLX_Types.Bytes_Ptr;
   begin
      pragma Warnings (Off, """Ctx.P.Request_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      RSP.RSP_Message.Take_Buffer (Ctx.P.Request_Ctx, Request_Buffer);
      pragma Warnings (On, """Ctx.P.Request_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      pragma Assert (Ctx.P.Slots.Slot_Ptr_1 = null);
      pragma Assert (Request_Buffer /= null);
      Ctx.P.Slots.Slot_Ptr_1 := Request_Buffer;
      pragma Assert (Ctx.P.Slots.Slot_Ptr_1 /= null);
      pragma Warnings (Off, """Ctx.P.Answer_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      RSP.RSP_Message.Take_Buffer (Ctx.P.Answer_Ctx, Answer_Buffer);
      pragma Warnings (On, """Ctx.P.Answer_Ctx"" is set by ""Take_Buffer"" but not used after the call");
      pragma Assert (Ctx.P.Slots.Slot_Ptr_2 = null);
      pragma Assert (Answer_Buffer /= null);
      Ctx.P.Slots.Slot_Ptr_2 := Answer_Buffer;
      pragma Assert (Ctx.P.Slots.Slot_Ptr_2 /= null);
      RSP.Server_Allocator.Finalize (Ctx.P.Slots);
      Ctx.P.Next_State := S_Final;
   end Finalize;

   procedure Reset_Messages_Before_Write (Ctx : in out Context'Class) with
     Pre =>
       Initialized (Ctx),
     Post =>
       Initialized (Ctx)
   is
   begin
      case Ctx.P.Next_State is
         when S_Receive_Request =>
            RSP.RSP_Message.Reset (Ctx.P.Request_Ctx, Ctx.P.Request_Ctx.First, Ctx.P.Request_Ctx.First - 1);
         when S_Store | S_Answer_Success | S_Get | S_Send_Data_Answer | S_Exception_Error | S_Invalid_Packet_Error | S_Got_Answer_Packet_Error | S_Stack_Full_Error | S_Setup_Answer | S_Send_Answer | S_Final =>
            null;
      end case;
   end Reset_Messages_Before_Write;

   procedure Tick (Ctx : in out Context'Class) is
   begin
      case Ctx.P.Next_State is
         when S_Receive_Request =>
            Receive_Request (Ctx);
         when S_Store =>
            Store (Ctx);
         when S_Answer_Success =>
            Answer_Success (Ctx);
         when S_Get =>
            Get (Ctx);
         when S_Send_Data_Answer =>
            Send_Data_Answer (Ctx);
         when S_Exception_Error =>
            Exception_Error (Ctx);
         when S_Invalid_Packet_Error =>
            Invalid_Packet_Error (Ctx);
         when S_Got_Answer_Packet_Error =>
            Got_Answer_Packet_Error (Ctx);
         when S_Stack_Full_Error =>
            Stack_Full_Error (Ctx);
         when S_Setup_Answer =>
            Setup_Answer (Ctx);
         when S_Send_Answer =>
            Send_Answer (Ctx);
         when S_Final =>
            null;
      end case;
      Reset_Messages_Before_Write (Ctx);
   end Tick;

   function In_IO_State (Ctx : Context'Class) return Boolean is
     (Ctx.P.Next_State in S_Receive_Request | S_Send_Data_Answer | S_Send_Answer);

   procedure Run (Ctx : in out Context'Class) is
   begin
      Tick (Ctx);
      while
         Active (Ctx)
         and not In_IO_State (Ctx)
      loop
         pragma Loop_Invariant (Initialized (Ctx));
         Tick (Ctx);
      end loop;
   end Run;

   procedure Read (Ctx : Context'Class; Chan : Channel; Buffer : out RFLX_Types.Bytes; Offset : RFLX_Types.Length := 0) is
      function Read_Pre (Message_Buffer : RFLX_Types.Bytes) return Boolean is
        (Buffer'Length > 0
         and then Offset < Message_Buffer'Length);
      procedure Read (Message_Buffer : RFLX_Types.Bytes) with
        Pre =>
          Read_Pre (Message_Buffer)
      is
         Length : constant RFLX_Types.Index := RFLX_Types.Index (RFLX_Types.Length'Min (Buffer'Length, Message_Buffer'Length - Offset));
         Buffer_Last : constant RFLX_Types.Index := Buffer'First - 1 + Length;
      begin
         Buffer (Buffer'First .. RFLX_Types.Index (Buffer_Last)) := Message_Buffer (RFLX_Types.Index (RFLX_Types.Length (Message_Buffer'First) + Offset) .. Message_Buffer'First - 2 + RFLX_Types.Index (Offset + 1) + Length);
      end Read;
      procedure RSP_RSP_Message_Read is new RSP.RSP_Message.Generic_Read (Read, Read_Pre);
   begin
      Buffer := (others => 0);
      case Chan is
         when C_Chan =>
            case Ctx.P.Next_State is
               when S_Send_Data_Answer | S_Send_Answer =>
                  RSP_RSP_Message_Read (Ctx.P.Answer_Ctx);
               when others =>
                  pragma Warnings (Off, "unreachable code");
                  null;
                  pragma Warnings (On, "unreachable code");
            end case;
      end case;
   end Read;

   procedure Write (Ctx : in out Context'Class; Chan : Channel; Buffer : RFLX_Types.Bytes; Offset : RFLX_Types.Length := 0) is
      Write_Buffer_Length : constant RFLX_Types.Length := Write_Buffer_Size (Ctx, Chan);
      function Write_Pre (Context_Buffer_Length : RFLX_Types.Length; Offset : RFLX_Types.Length) return Boolean is
        (Buffer'Length > 0
         and then Context_Buffer_Length = Write_Buffer_Length
         and then Offset <= RFLX_Types.Length'Last - Buffer'Length
         and then Buffer'Length + Offset <= Write_Buffer_Length);
      procedure Write (Message_Buffer : out RFLX_Types.Bytes; Length : out RFLX_Types.Length; Context_Buffer_Length : RFLX_Types.Length; Offset : RFLX_Types.Length) with
        Pre =>
          Write_Pre (Context_Buffer_Length, Offset)
          and then Offset <= RFLX_Types.Length'Last - Message_Buffer'Length
          and then Message_Buffer'Length + Offset = Write_Buffer_Length,
        Post =>
          Length <= Message_Buffer'Length
      is
      begin
         Length := Buffer'Length;
         Message_Buffer := (others => 0);
         Message_Buffer (Message_Buffer'First .. RFLX_Types.Index (RFLX_Types.Length (Message_Buffer'First) - 1 + Length)) := Buffer;
      end Write;
      procedure RSP_RSP_Message_Write is new RSP.RSP_Message.Generic_Write (Write, Write_Pre);
   begin
      case Chan is
         when C_Chan =>
            case Ctx.P.Next_State is
               when S_Receive_Request =>
                  RSP_RSP_Message_Write (Ctx.P.Request_Ctx, Offset);
               when others =>
                  pragma Warnings (Off, "unreachable code");
                  null;
                  pragma Warnings (On, "unreachable code");
            end case;
      end case;
   end Write;

end RFLX.RSP.Server;

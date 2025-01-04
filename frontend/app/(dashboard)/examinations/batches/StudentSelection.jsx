"use client";

import {
  flexRender,
  getCoreRowModel,
  getFilteredRowModel,
  getSortedRowModel,
  useReactTable,
} from "@tanstack/react-table";
import { ArrowUpDown, ChevronDown, MoreHorizontal } from "lucide-react";
import lodash from "lodash";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Input } from "@/components/ui/input";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useEffect, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { getStudentByDegShort } from "@/utils/apiRequests/user.api";
import { MdCancel } from "react-icons/md";

const StudentSelection = ({
  feedDegShort,
  selectedStudents,
  setSelectedStudents,
  feedId,
  oldDataRefetch,
}) => {
  const [sorting, setSorting] = useState([]);
  const [columnFilters, setColumnFilters] = useState([]);
  const [columnVisibility, setColumnVisibility] = useState({});
  const [rowSelection, setRowSelection] = useState({});
  const [filteredStuData, setFilteredStuData] = useState([]);
  const [searchValue, setSearchValue] = useState("");

  const { data: stuData, refetch } = useQuery({
    queryFn: () => getStudentByDegShort(feedDegShort),
    queryKey: ["students", "faculty", "short", feedDegShort],
    enabled: false,
  });

  const columns = [
    {
      id: "select",
      header: ({ table }) => (
        <Checkbox
          checked={filteredStuData.every((ele) =>
            selectedStudents?.includes(ele.s_id)
          )}
          onCheckedChange={(value) => {
            setSelectedStudents((cur) => {
              if (lodash.isEqual(selectedStudents, stuData)) {
                return [];
              } else if (
                filteredStuData.every((ele) =>
                  selectedStudents?.includes(ele.s_id)
                )
              ) {
                let filtered = filteredStuData.map((obj) => obj.s_id);
                let temp = selectedStudents.filter(
                  (ele) => !filtered.includes(ele)
                );
                return temp;
              } else {
                let temp = filteredStuData?.map((stu) => stu.s_id);

                let set = new Set([...cur, ...temp]);
                return Array.from(set);
              }
            });
          }}
          aria-label="Select all"
        />
      ),
      cell: ({ row }) => (
        <Checkbox
          checked={selectedStudents?.includes(row.original.s_id)}
          onCheckedChange={(value) =>
            setSelectedStudents((cur) => {
              const temp = [...cur];
              if (cur.includes(row.original.s_id)) {
                let ind = cur.indexOf(row.original.s_id);
                temp.splice(ind, 1);
              } else {
                temp.push(row.original.s_id);
              }
              return temp;
            })
          }
          aria-label="Select row"
        />
      ),
      enableSorting: false,
      enableHiding: false,
    },
    {
      accessorKey: "user_name",
      header: "User name",
      cell: ({ row }) => (
        <div className="capitalize">{row.getValue("user_name")}</div>
      ),
    },
    {
      accessorKey: "name",
      header: ({ column }) => {
        return (
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
          >
            Name
            <ArrowUpDown />
          </Button>
        );
      },
      cell: ({ row }) => <div className="">{row.getValue("name")}</div>,
    },
  ];

  const onSearchChange = (e) => {
    setSearchValue(e.target.value);
  };

  const onClearClicked = () => setSearchValue("");

  useEffect(() => {
    if (stuData) {
      let filtData = searchValue
        ? stuData.filter(
            (item) =>
              item.name.toLowerCase().includes(searchValue.toLowerCase()) ||
              item.user_name.toLowerCase().includes(searchValue.toLowerCase())
          )
        : stuData;

      setFilteredStuData(filtData);
    }
  }, [searchValue, stuData]);

  const table = useReactTable({
    data: filteredStuData,
    columns,
    onSortingChange: setSorting,
    onColumnFiltersChange: setColumnFilters,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    onColumnVisibilityChange: setColumnVisibility,
    onRowSelectionChange: setRowSelection,
    state: {
      sorting,
      columnFilters,
      columnVisibility,
      rowSelection,
    },
  });

  useEffect(() => {
    if (feedId) {
      refetch();
    }
  }, [feedId]);

  useEffect(() => {
    console.log(feedId);
    if (feedId) {
      oldDataRefetch();
    }
  }, [feedId]);

  return (
    <div className="w-full h-[60vh] mb-2">
      <div className="flex items-center py-2 px-1 gap-10">
        <div className="bg-white rounded-md flex relative w-full">
          <Input
            placeholder="Search by student id or name"
            onChange={(e) => onSearchChange(e)}
            value={searchValue}
            className="w-full"
          />
          <span
            className={`${
              searchValue ? "opacity-100 inline-block" : "opacity-0 hidden"
            } text-sm font-medium text-slate-700 absolute top-2 right-2 transition-all duration-200`}
            onClick={onClearClicked}
          >
            <MdCancel className="size-5 cursor-pointer" />
          </span>
        </div>

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="outline" className="ml-auto">
              Columns <ChevronDown />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            {table
              .getAllColumns()
              .filter((column) => column.getCanHide())
              .map((column) => {
                return (
                  <DropdownMenuCheckboxItem
                    key={column.id}
                    className="capitalize"
                    checked={column.getIsVisible()}
                    onCheckedChange={(value) =>
                      column.toggleVisibility(!!value)
                    }
                  >
                    {column.id}
                  </DropdownMenuCheckboxItem>
                );
              })}
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
      <div className="rounded-md border max-h-[370px] h-[350px] overflow-y-scroll">
        <Table>
          <TableHeader>
            {table.getHeaderGroups().map((headerGroup) => (
              <TableRow key={headerGroup.id}>
                {headerGroup.headers.map((header) => {
                  return (
                    <TableHead key={header.id}>
                      {header.isPlaceholder
                        ? null
                        : flexRender(
                            header.column.columnDef.header,
                            header.getContext()
                          )}
                    </TableHead>
                  );
                })}
              </TableRow>
            ))}
          </TableHeader>
          <TableBody>
            {table.getRowModel().rows?.length ? (
              table.getRowModel().rows.map((row) => (
                <TableRow
                  key={row.id}
                  data-state={row.getIsSelected() && "selected"}
                >
                  {row.getVisibleCells().map((cell) => (
                    <TableCell key={cell.id}>
                      {flexRender(
                        cell.column.columnDef.cell,
                        cell.getContext()
                      )}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell
                  colSpan={columns.length}
                  className="h-24 text-center"
                >
                  No results.
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>
      <div className="flex items-center justify-between space-x-2 py-4 mx-1">
        <div className="flex-1 text-sm text-muted-foreground">
          {selectedStudents?.length} of {stuData?.length} students selected.
        </div>
        <div className="flex-1 text-sm text-muted-foreground text-end">
          {searchValue
            ? `${filteredStuData?.length} ${
                filteredStuData?.length == 1 ? "match" : "matches"
              }`
            : ""}
        </div>
      </div>
    </div>
  );
};

export default StudentSelection;

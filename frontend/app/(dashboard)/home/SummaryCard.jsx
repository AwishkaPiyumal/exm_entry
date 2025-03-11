import {
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

const SummaryCard = ({ title, desc }) => {
  return (
    <Card className={`w-[22%] max-w-[22%] rounded-none`}>
      <CardHeader>
        <CardTitle className={`text-5xl text-center font-light`}>
          {title}
        </CardTitle>
        <CardDescription className={`font-bold text-sm text-center uppercase`}>
          {desc}
        </CardDescription>
      </CardHeader>
    </Card>
  );
};

export default SummaryCard;
